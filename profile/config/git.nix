{ config, pkgs, flakeSettings, ... }:
# COMMENT
{
  programs.git.enable = true;
  programs.git.userName = flakeSettings.username;
  programs.git.userEmail = flakeSettings.email;
}
