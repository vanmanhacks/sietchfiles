{ pkgs, ... }:

{
  programs.proxychains = {
    package = pkgs.proxychains-ng;
    proxies = ;
      };
  }
