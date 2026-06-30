{ config, pkgs, inputs, flakeSettings, ... }:

{

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    shellInit = ''
      zsh-newuser-install() {:;}
    '';

    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      cat = "bat";
      grep = "rg";
      nv = "nvim";
      nf = "cd ~/.nixfiles";
      cf = "clear; fastfetch";
      cd = "z";
    };

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
      "HIST_FCNTL_LOCK"
      "NO_HIST_SAVE_BY_COPY"
    ];

  };
}
