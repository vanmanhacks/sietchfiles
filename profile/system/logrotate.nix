{ pkgs, ... }:

{

  services.logrotate.enable = true;
  services.logrotate.settings = {

    # --- Audit Log Rotation ---
    "/var/log/**/*.log" = {
      size = "50M";
      rotate = 4;
      compress = true;
      missingok = true;
      notifempty = true;
      copytruncate = true;
      create = "0600 root root";
    };

    # --- AdGuard Home Logs ---
    "/var/log/adguardhome/*.log" = {
      size = "50M";
      rotate = 4;
      compress = true;
      missingok = true;
      notifempty = true;
      create = "0640 adguardhome adguardhome";
    };

    # --- Docker Container Logs ---
    "/var/lib/docker/containers/*/*.log" = {
      size = "100M";
      rotate = 2;
      compress = true;
      missingok = true;
      copytruncate = true;
    };

    # --- DNSCrypt-proxy Logs ---
    "/var/log/dnscrypt-proxy/*.log" = {
      size = "50M";
      rotate = 4;
      compress = true;
      missingok = true;
      notifempty = true;
    };

    # --- Tor Logs ---
    "/var/log/tor/*.log" = {
      size = "50M";
      rotate = 4;
      compress = true;
      missingok = true;
      create = "0640 tor tor";
    };

    # --- Login Record Rotation ---
    "/var/log/btmp" = {
      monthly = true;
      rotate = 1;
      compress = true;
      missingok = true;
      create = "0600 root utmp";
    };

    "/var/log/wtmp" = {
      monthly = true;
      rotate = 1;
      compress = true;
      missingok = true;
      create = "0664 root utmp";
    };
  };

  services.journald.storage = "persistent";
  services.journald.extraConfig = ''
    SystemMaxUse=250M
  '';
}
