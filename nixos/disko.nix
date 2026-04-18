# disko 分区布局（详见 DISKO.md）
# 两种使用场景：
#   1. CLI 调用（install.sh 装机时）：
#      nix run github:nix-community/disko -- \
#        --mode destroy,format,mount ./nixos/disko.nix --argstr device /dev/sda
#   2. NixOS 模块导入（nyx-vm-2604 及以后的 -yymm target 使用），
#      device 可被 local.nix 覆盖
{ device ? "/dev/sda", lib, ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    device = lib.mkDefault device;
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
