{ config, pkgs, inputs, flakeSettings, ... }:

{

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "(0x9A348E)$username$hostname(fg:0x9A348E bg:0xDA627D)$directory$line_break$character";
      character = {
        format = "$symbol ";
        vicmd_symbol = "[](bold green)";
        disabled = false;
        success_symbol = "[](bold green) ";
        error_symbol = "[](bold red) ";
      };

      directory = {
        disabled = false;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        home_symbol = "~";
        read_only = "";
        read_only_style = "red";
        repo_root_format = "[$before_root_path]($style)[$repo_root]($repo_root_style)[$path]($style)[$r
ead_only]($read_only_style) ";
        style = "cyan bold bg:0xDA627D";
        truncate_to_repo = true;
        truncation_length = 3;
        truncation_symbol = "…/";
        use_logical_path = true;
        use_os_path_sep = true;
      };

      username = {
        format = "[$user]($style) ";
        show_always = true;
        style_root = "red bold bg:0x9A348E";
        style_user = "blue bold bg:0x9A348E";
        disabled = false;
      };
    };
  };

}
