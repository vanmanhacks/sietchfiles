{ config, pkgs, lib, flakeSettings, ... }:

{
  environment.persistence."/persist" = {
    directories = [
      "/etc/audit"
      "/etc/ghola"
      "/etc/mullvad-vpn"
      "/etc/NetworkManager"
      "/etc/nixos"
      "/etc/other-memory"
      "/etc/ssh"
      "/var/cache"
      "/var/db"
      "/var/lib"
      "/var/log"
      { directory = "/etc/searxng"; user = "${flakeSettings.username}"; group = "${flakeSettings.username}"; mode = "u-rwx,g=rx,o="; }
    ];

    files = [
      "/etc/machine-id"
      #"/etc/passwd"
      #"/etc/shadow"
      #"/etc/group"
    ];

    users.${flakeSettings.username} = {
      directories = [
        ".config"
        ".local"
        ".cache"

        ".claude"
        ".hermes"
        ".honcho"

        ".gnupg"
        ".ssh"
        ".pki"

        ".var"

        ".nixfiles"
        ".nixBU"
        ".icons"

        "Applications"
        "Library"
        "Operations"
        "Projects"
      ];

      files = [
        ".bash_history"
        ".zsh_history"
        ".gitconfig"
        ".viminfo"
      ];
    };
  };
}
