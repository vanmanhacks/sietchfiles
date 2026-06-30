{ flakeSettings, ... }:

{
  #automatically deploy updates
  system.autoUpgrade = {
    enable = true;
    #randomizedDelaySec = "600"; #adds 0-10 minutes to trigger time to stagger updates
    operation = "boot"; #deploys update as new boot entry. use the default setting of "switch" for immediate effect.
    dates = "daily";
    flake = "/home/${flakeSettings.username}/.nixfiles";
    flags = [
      "-L"
    ];
  };
  #clean up old deployments
  nix.optimise.automatic = true;
  nix.settings.max-jobs = "auto";
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 21d";
  };
}
