{ config, pkgs, lib, flakeSettings, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    plugins = [
      pkgs.tmuxPlugins.nord
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.sysstat
      pkgs.tmuxPlugins.continuum
      pkgs.tmuxPlugins.tmux-sessionx
      pkgs.tmuxPlugins.better-mouse-mode
      #pkgs.tmuxPlugins.dotbar
    ];
    sensibleOnTop = true;
    baseIndex = 1;
    mouse = true;
  };
}
