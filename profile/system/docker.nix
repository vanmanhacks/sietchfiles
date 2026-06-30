{ pkgs, lib, flakeSettings, ... }:

#assert lib.asserts.assertOneOf "storageDriver" storageDriver [
#  null
#  "aufs"
#  "btrfs"
#  "devicemapper"
#  "overlay"
#  "overlay2"
#  "zfs"
#];

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "btrfs";
    autoPrune.enable = true;
    daemon.settings = {
      experimental = true;
      dns = [ "127.0.0.1" "9.9.9.9" ];
    };
    package = pkgs.docker_29;
  };

  users.users.${flakeSettings.username}.extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [
    docker_29
    docker-compose
    lazydocker
  ];
}
