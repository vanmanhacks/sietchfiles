{ ... }:

{
  imports = [
    #    ./clamav.nix
    # ./cronjobs.nix
    # ./dnscrypt-proxy.nix
    ./firewall.nix
    ./kernel.nix
    ./usbguard.nix

    # ─── Network-facing daemons ───
    # ./systemd-services/sshd.nix
    # ./systemd-services/docker.nix
    # ./systemd-services/nix-daemon.nix
    # ./systemd-services/adguardhome.nix
    # ./systemd-services/dnscrypt-proxy.nix
    # ./systemd-services/tor.nix
    # ./systemd-services/unbound.nix
    # ./systemd-services/tailscaled.nix

    # ─── Core system services ───
    # ./systemd-services/systemd-journald.nix
    # ./systemd-services/systemd-udevd.nix
    # ./systemd-services/systemd-machined.nix
    # ./systemd-services/systemd-rfkill.nix
    # ./systemd-services/auditd.nix
    # ./systemd-services/nscd.nix

    # ─── D-Bus ───
    # ./systemd-services/dbus.nix

    # ─── TTY / console ───
    # ./systemd-services/getty.nix
    # ./systemd-services/autovt.nix

    # ─── Password prompts ───
    # ./systemd-services/systemd-ask-password-console.nix
    # ./systemd-services/systemd-ask-password-wall.nix

    # ─── User services ───
    # ./systemd-services/user.nix

    # ─── System-wide hardening (import LAST — hidepid=2, dbus-broker, execWheelOnly) ───
    # ./systemd-services/general.nix

    # ─── Rescue / emergency shell ───
    # ./systemd-services/rescue.nix

    # ─── Console reload ───
    # ./systemd-services/reload-systemd-vconsole-setup.nix

    # ─── Server N/A (kept for reference) ───
    #./systemd-services/display-manager.nix
    #./systemd-services/bluetooth.nix
    #./systemd-services/wpa_supplicant.nix
    #./systemd-services/NetworkManager.nix
    #./systemd-services/NetworkManager-dispatcher.nix
    #./systemd-services/colord.nix
    #./systemd-services/rtkit.nix
    #./systemd-services/accounts-daemon.nix
    #./systemd-services/cups.nix
    #./systemd-services/blocky.nix
    #./systemd-services/acipd.nix
    # ./systemd-services/dbus-broker.nix
  ];

  custom.security.usbguard.enable = true;

  #custom audit rules
  #security.audit.rules = [
  #"-w /home/${flakeSettings.username}/.nixfiles -p wa -k nixos_config_change"
  #"-w /etc/nixos/ -p wa -k nixos_config_change"
  #];

  #randomize MAC
  # networking.networkmanager = {
  #   ethernet.macAddress = "stable";
  #   wifi.macAddress = "random";
  # };

  #sudo-rs
  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  # PAM Account Lockout
  security.pam.services.sshd.failDelay.enable = true;

  #wayland envars
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

}
