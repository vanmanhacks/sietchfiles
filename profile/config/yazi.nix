{ config, pkgs, lib, flakeSettings, ... }:

{
  programs.yazi = {
    enable = true;

  };
  environment.systemPackages = with pkgs;
    [
      yaziPlugins.nord
      yaziPlugins.git
      yaziPlugins.ouch
      yaziPlugins.glow
      yaziPlugins.bypass
      yaziPlugins.starship
      yaziPlugins.mediainfo
      yaziPlugins.toggle-pane
      yaziPlugins.full-border
      yaziPlugins.smart-enter
      yaziPlugins.smart-paste
      #yaziPlugins.wl-clipboard
      yaziPlugins.rich-preview
      yaziPlugins.smart-filter
      yaziPlugins.restore
    ];
}
