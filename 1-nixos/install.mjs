import { exec } from 'node:child_process'
import { promisify } from 'util'
const pExec = promisify(exec)

const part = async () => { // need sudo 
  // await pExec('parted /dev/nvme0n1 -- mklabel gpt')
  exec('parted /dev/nvme0n1 -- mkpart primary 512MiB 100%')
   exec('parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB')
  exec('parted /dev/nvme0n1 -- set 2 esp on')
  exec('mkfs.ext4 -L nixos /dev/nvme0n1p1')
  exec('mkfs.fat -F 32 -n boot /dev/nvme0n1p2')
  exec('mount /dev/disk/by-label/nixos /mnt')
  exec('mkdir -p /mnt/boot')
  exec('mount /dev/disk/by-label/boot /mnt/boot')
  exec('nixos-generate-config --root /mnt')
}
const df = async () => { // need sudo 
  // await pExec('git clone https://github.com/blurname/df.git')
  await pExec('mv -f ./mini-configuration.nix /mnt/etc/nixos/configuration.nix')
}
const proxy = async () => {
  console.log('start proxy')
  await pExec('docker run -d   --restart=always   --privileged   --network=host   --name v2raya   -e V2RAYA_ADDRESS=0.0.0.0:2017   -v /lib/modules:/lib/modules:ro   -v /etc/resolv.conf:/etc/resolv.conf   -v /etc/v2raya:/etc/v2raya   mzz2017/v2raya')
}

const main = async () => {
  const [, , func] = process.argv
  if (func === 'part') {
    await part()
  } else if (func === 'df') {
    await df()
  } else if(func === 'proxy'){
    await proxy()
  }
}
main()
