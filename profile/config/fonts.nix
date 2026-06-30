{ config, pkgs, inputs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    noto-fonts
  ];
}
