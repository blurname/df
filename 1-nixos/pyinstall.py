# it is comes from https://github.com/samuela/nixos-up
import os
import re
import subprocess
import sys
import time
from getpass import getpass
from math import sqrt
from pathlib import Path

if os.geteuid() != 0:
  sys.exit("script must be run as root!")

if subprocess.run(["mountpoint", "/mnt"]).returncode == 0:
  sys.exit("Something is already mounted at /mnt!")

sys_block = Path("/sys/block/")
disks = [p.name for p in sys_block.iterdir() if (p / "device").is_dir()]

def disk_size_kb(disk: str) -> int:
  # Linux reports sizes in 512 byte units, as opposed to 1K units.
  with (sys_block / disk / "size").open() as f:
    return int(f.readline().strip()) / 2

# Vendor and model are not always present. See https://github.com/samuela/nixos-up/issues/2 and https://github.com/samuela/nixos-up/issues/6.
def maybe_read_first_line(path: Path) -> str:
  if path.is_file():
    with path.open() as f:
      return f.readline().strip()
  return ""

print("\nDetected the following disks:\n")
for i, name in enumerate(disks):
  vendor = maybe_read_first_line(sys_block / name / "device" / "vendor")
  model = maybe_read_first_line(sys_block / name / "device" / "model")
  size_gb = float(disk_size_kb(name)) / 1024 / 1024
  print(f"{i + 1}: /dev/{name:12} {vendor:12} {model:32} {size_gb:.3f} Gb total")
print()

def ask_disk() -> int:
  sel = input(f"Which disk number would you like to install onto (1-{len(disks)})? ")
  try:
    ix = int(sel)
    if 1 <= ix <= len(disks):
      # We subtract to maintain 0-based indexing.
      return ix - 1
    else:
      print(f"Input must be between 1 and {len(disks)}.\n")
      return ask_disk()
  except ValueError:
    print(f"Input must be an integer.\n")
    return ask_disk()

selected_disk = ask_disk()
print()

selected_disk_name = disks[selected_disk]
print(f"Proceeding will entail repartitioning and formatting /dev/{selected_disk_name}.\n")
print(f"!!! ALL DATA ON /dev/{selected_disk_name} WILL BE LOST !!!\n")

print("Ok, will begin installing in 10 seconds. Press Ctrl-C to cancel.\n")
sys.stdout.flush()
time.sleep(10)

def run(args):
  print(f">>> {' '.join(args)}")
  subprocess.run(args, check=True)

### Partitioning
# Whether or not we are on a (U)EFI system
efi = Path("/sys/firmware/efi").is_dir()
if efi:
  print("Detected EFI/UEFI boot. Proceeding with a GPT partition scheme...")
  # See https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning-UEFI
  # Create GPT partition table.
  run(["parted", f"/dev/{selected_disk_name}", "--", "mklabel", "gpt"])
  # Create boot partition with first 512MiB.
  run(["parted", f"/dev/{selected_disk_name}", "--", "mkpart", "ESP", "fat32", "1MiB", "512MiB"])
  # Set the partition as bootable
  run(["parted", f"/dev/{selected_disk_name}", "--", "set", "1", "esp", "on"])
  # Create root partition after the boot partition.
  run(["parted", f"/dev/{selected_disk_name}", "--", "mkpart", "primary", "512MiB", "100%"])
else:
  print("Did not detect an EFI/UEFI boot. Proceeding with a legacy MBR partitioning scheme...")
  run(["parted", f"/dev/{selected_disk_name}", "--", "mklabel", "msdos"])
  run(["parted", f"/dev/{selected_disk_name}", "--", "mkpart", "primary", "1MiB", "100%"])

### Formatting
# Different linux device drivers have different partition naming conventions.
def partition_name(disk: str, partition: int) -> str:
  if disk.startswith("sd"):
    return f"{disk}{partition}"
  elif disk.startswith("nvme"):
    return f"{disk}p{partition}"
  else:
    print("Warning: this type of device driver has not been thoroughly tested with nixos-up, and its partition naming scheme may differ from what we expect. Please open an issue at https://github.com/samuela/nixos-up/issues.")
    return f"{disk}{partition}"

def wait_for_partitions():
  for _ in range(10):
    if Path(f"/dev/{partition_name(selected_disk_name, 1)}").exists():
      return
    else:
      time.sleep(1)
  print(f"WARNING: Waited for /dev/{partition_name(selected_disk_name, 1)} to show up but it never did. Things may break.")

wait_for_partitions()

if efi:
  # EFI: The first partition is boot and the second is the root partition.
  # This occasionally fails with "unable to open /dev/"
  run(["mkfs.fat", "-F", "32", "-n", "boot", f"/dev/{partition_name(selected_disk_name, 1)}"])
  run(["mkfs.ext4", "-L", "nixos", f"/dev/{partition_name(selected_disk_name, 2)}"])
else:
  # MBR: The first partition is the root partition and there's no boot partition.
  run(["mkfs.ext4", "-L", "nixos", f"/dev/{partition_name(selected_disk_name, 1)}"])

### Mounting
# Sometimes when switching between BIOS/UEFI, we need to force the kernel to
# refresh its block index. Otherwise we get "special device does not exist"
# errors. The answer here https://askubuntu.com/questions/334022/mount-error-special-device-does-not-exist
# suggests `blockdev --rereadpt` but that doesn't seem to always work.
def refresh_block_index():
  for _ in range(10):
    try:
      run(["blockdev", "--rereadpt", f"/dev/{selected_disk_name}"])
      # Sometimes it takes a second for re-reading the partition table to take.
      time.sleep(1)
      if Path("/dev/disk/by-label/nixos").exists():
        return
    except subprocess.CalledProcessError:
      # blockdev failed, likely due to "ioctl error on BLKRRPART: Device or resource busy"
      pass
  print(f"WARNING: Failed to re-read the block index on /dev/{selected_disk_name}. Things may break.")

refresh_block_index()

# This occasionally fails with "/dev/disk/by-label/nixos does not exist".
run(["mount", "/dev/disk/by-label/nixos", "/mnt"])
if efi:
  run(["mkdir", "-p", "/mnt/boot"])
  run(["mount", "/dev/disk/by-label/boot", "/mnt/boot"])

### Generate config
run(["nixos-generate-config", "--root", "/mnt"])

config_path = "/mnt/etc/nixos/configuration.nix"
with open(config_path, "r") as f:
  config = f.read()

# Non-EFI systems require boot.loader.grub.device to be specified.
if not efi:
  config = config.replace("boot.loader.grub.version = 2;", f"boot.loader.grub.version = 2;\n  boot.loader.grub.device = \"/dev/{selected_disk_name}\";\n")

# ram_bytes = psutil.virtual_memory().total
# print(f"Detected {(ram_bytes / 1024 / 1024 / 1024):.3f} Gb of RAM...")

# The Ubuntu guidelines say max(1GB, sqrt(RAM)) for swap on computers not
# utilizing hibernation. In the case of hibernation, max(1GB, RAM + sqrt(RAM)).
# See https://help.ubuntu.com/community/SwapFaq.
# swap_bytes = max(int(sqrt(ram_bytes)), 1024 * 1024 * 1024)
# swap_mb = int(swap_bytes / 1024 / 1024)
# hibernation_swap_bytes = swap_bytes + ram_bytes
# hibernation_swap_mb = int(hibernation_swap_bytes / 1024 / 1024)

# Match against the end of the file. Note that because we're not using re.MULTILINE here $ matches the end of the file.
# config = re.sub(r"\}\s*$", "\n".join([
  # f"  # Configure swap file. Sizes are in megabytes. Default swap is",
  # f"  # max(1GB, sqrt(RAM)) = {swap_mb}. If you want to use hibernation with",
  # f"  # this device, then it's recommended that you use",
  # f"  # RAM + max(1GB, sqrt(RAM)) = {hibernation_swap_mb:.3f}.",
  # f"  swapDevices = [ {{ device = \"/swapfile\"; size = {swap_mb}; }} ];",
  # "}",
  # ""
# ]), config)

with open(config_path, "w") as f:
  f.write(config)

# Finally do the install!
run(["nixos-install", "--no-root-passwd"])
