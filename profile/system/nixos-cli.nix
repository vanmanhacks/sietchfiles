{ config, pkgs, ... }:

{
  services.nixos-cli = {
    enable = true;
    config = {
      use_nvd = true;
    };
  };
}

