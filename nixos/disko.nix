# disko 分区布局（install-time-only，详见 DISKO.md）
# 通过 CLI 调用：
#   nix run github:nix-community/disko -- \
#     --mode destroy,format,mount ./nixos/disko.nix --argstr device /dev/sda
{ device ? "/dev/sda", lib, ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
