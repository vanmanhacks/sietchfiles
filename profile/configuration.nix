{ modulesPath
, lib
, pkgs
, ...
} @ args:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    # ./config/adguard.nix
    ./config/fonts.nix
    # ./config/ghola.nix
    # ./config/ghola-aliases.nix
    ./config/hermes-browser-cdp.nix
    ./config/hermes-dashboard.nix
    ./config/offsec_packages.nix
    ./config/other-memory.nix
    ./config/signal-cli.nix
    ./config/starship.nix
    ./config/tailscale.nix
    ./config/yazi.nix
    ./config/zoxide.nix
    ./config/zsh.nix
    ./system/autoupdate.nix
    ./system/dns-stack.nix
    ./system/docker.nix
    ./system/fwupd.nix
    ./system/hardening/audit.nix
    ./system/hardening/hardening.nix
    ./system/hardware-configuration.nix
    ./system/lanza.nix
    ./system/logrotate.nix
    ./system/network.nix
    ./system/persist.nix
    ./system/pkgs.nix
    ./system/schedulers.nix
    ./system/ssh.nix
    ./system/system.nix
    ./system/users.nix
  ];

  system.stateVersion = "25.05";
}
