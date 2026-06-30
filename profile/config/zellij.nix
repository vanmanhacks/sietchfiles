{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      theme = "nord";
      pane_frames = true;
      default_shell = "zsh";
      mouse_mode = true;
      copy_command = "wl-copy";
      scroll_buffer_size = 10000;
      copy_on_select = true;
      disable_automatic_asset_installation = true;
      default_mode = "locked";
      session_serialization = true;
      show_startup_tips = false;
      # default_layout = "compact";
      # simplified_ui = true;
    };

    # Locked mode: Ctrl+b acts as tmux prefix for the 3 bindings below.
    # Ctrl+g still works (from defaults) to enter full Zellij Normal mode.
    # Flat chord syntax: `bind "key1" "key2" { Action; }`
    # extraConfig = ''
    #   keybinds {
    #     locked {
    #       bind "Ctrl b" "\"" { NewPane "Down"; }
    #       bind "Ctrl b" "%" { NewPane "Right"; }
    #       bind "Ctrl b" "d" { Detach; }
    #     }
    #   }
    # '';
  };
}
