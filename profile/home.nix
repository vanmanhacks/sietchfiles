{ flakeSettings, ... }:

{
  imports = [
    ./config/broot.nix
    ./config/helix.nix
    ./config/rust.nix
    ./config/tmux.nix
    ./config/zellij.nix
  ];

  programs.yazi.enableZshIntegration = true;

  home.username = flakeSettings.username;
  home.homeDirectory = ("/home" + ("/" + flakeSettings.username));

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      urls = [ "qwmu:///system" ];
    };
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
