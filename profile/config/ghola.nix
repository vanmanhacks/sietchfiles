{ config, pkgs, lib, ... }:

{
  # ─── Host Identity ───
  # networking.hostName = "CHANGE_ME_HOSTNAME";

  # ─── User ───
  # users.users."CHANGE_ME_USERNAME" = {
  # isNormalUser = true;
  # extraGroups = [ "wheel" "docker" "networkmanager" ];
  # initialPassword = "CHANGE_ME_ON_FIRST_BOOT";
  # Force password change on first login (expires immediately)
  # password = pkgs.lib.mkForce "!";  # locked — must use initialPassword and change it
  # };

  # ─── Docker ───
  # virtualisation.docker.enable = true;
  # virtualisation.docker.autoPrune.enable = true;
  # virtualisation.docker.autoPrune.dates = "weekly";

  # ─── Tailscale (Remote Admin Only) ───
  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Only Tailscale interface gets inbound access
    # interfaces."tailscale0".allowedTCPPorts = [ 22 ];
  };

  # ─── Hermes Agent ───
  # Hermes is managed externally by the llm-agents.nix flake (numtide).
  # It is NOT declared here — the llm-agents.nix module handles the
  # Hermes binary, service, and configuration.
  #
  # GHOLA integrates with this pre-configured Hermes instance via:
  #   1. Skills deployed to ~/.hermes/skills/ghola/ (see Phase 6 of docs)
  #   2. A 'recon' profile created with `hermes profile create recon`
  #   3. Cron jobs registered under the recon profile for decision gates
  #   4. Signal alerts sent via the signal-cli daemon (Hermes gateway prerequisite)
  #
  # The recon profile is used for on-demand interactive analysis:
  #   hermes --profile recon -s ghola-recon -s ghola-triage chat -q "..."
  #

  # ─── Docker Compose Stack ───
  systemd.services.ghola-stack = {
    description = "GHOLA Docker Compose Stack (VPN, DB, Proxy, Recon)";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${config.users.users.${flakeSettings.username}.home}/ghola/docker-workspace";
      # Render wg0.conf from env vars before starting — WireGuard won't expand shell variables
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'test -f /etc/ghola/env && set -a && source /etc/ghola/env && set +a && envsubst < wg0.conf > wg0_rendered.conf && mv wg0_rendered.conf wg0.conf || echo \"[!] /etc/ghola/env not found — WireGuard may fail to start\"'";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --build";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      ExecStopPost = "${pkgs.docker-compose}/bin/docker-compose down -v";
    };
  };

  # ─── Pipeline (2-Tier: Daily Light + Weekly Deep) ───
  # Daily: fast scan of new subdomains only (~2h at 16KB/s)
  # Weekly: full deep scan including feroxbuster (~12-18h at 16KB/s)
  systemd.services.ghola-daily-light = {
    description = "GHOLA Daily Light Pipeline (new subdomains only)";
    serviceConfig = {
      Type = "oneshot";
      User = "${flakeSettings.username}";
      WorkingDirectory = "${config.users.users.${flakeSettings.username}.home}/ghola/scans/daily-light";
      EnvironmentFile = "/etc/ghola/env";
      ExecStart = "${pkgs.bash}/bin/bash ${config.users.users.${flakeSettings.username}.home}/ghola/pipeline/daily-light.sh";
    };
  };

  systemd.timers.ghola-daily-light = {
    description = "Daily at 02:00 UTC";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };
  };

  systemd.services.ghola-weekly-deep = {
    description = "GHOLA Weekly Deep Pipeline (full scan + wordlist mining)";
    serviceConfig = {
      Type = "oneshot";
      User = "${flakeSettings.username}";
      WorkingDirectory = "${config.users.users.${flakeSettings.username}.home}/ghola/scans/weekly-deep";
      EnvironmentFile = "/etc/ghola/env";
      ExecStart = "${pkgs.bash}/bin/bash ${config.users.users.${flakeSettings.username}.home}/ghola/pipeline/weekly-deep.sh";
    };
  };

  systemd.timers.ghola-weekly-deep = {
    description = "Weekly deep scan Sunday at 02:00 UTC";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 02:00:00";
      Persistent = true;
    };
  };

  # ─── Security Hardening ───
  # DUAL-LAYER PROTECTION against traffic leaks.
  #
  # Layer 1 (PRIMARY): WireGuard kill switch inside the container namespace.
  #   Configured in wg0.conf PostUp/PostDown. Drops all traffic NOT routed
  #   through the wg0 interface. If VPN drops, traffic stops — fail-closed.
  #
  # Layer 2 (SECONDARY): Host firewall blocks non-WireGuard egress from
  #   Docker bridge to the WAN interface. Catches misconfigured containers
  #   that aren't using the VPN namespace. WireGuard traffic (UDP/51820)
  #   to the VPN endpoint is explicitly allowed.
  #
  # WARNING: <wan_iface> must be set to the actual physical interface
  # (e.g., enp0s31f6, eth0, wlp1s0). <vpn_endpoint> is the WireGuard peer IP.
  networking.firewall.extraCommands = ''
    # Resolve WAN interface and VPN endpoint from environment or defaults
    WAN_IFACE=''${WAN_IFACE:-eth0}
    VPN_EP=''${VPN_ENDPOINT:-1.2.3.4}
    # Allow WireGuard-encrypted UDP to VPN endpoint from Docker containers
    iptables -I FORWARD 1 -i docker0 -o "$WAN_IFACE" -p udp --dport 51820 -d "$VPN_EP" -j ACCEPT
    # Log and drop ALL other Docker bridge traffic to the WAN
    iptables -I FORWARD 2 -i docker0 -o "$WAN_IFACE" -j LOG --log-prefix "GHOLA_LEAK_BLOCKED: "
    iptables -I FORWARD 3 -i docker0 -o "$WAN_IFACE" -j DROP
  '';

  # Alternative: If the physical interface name changes (Wi-Fi vs Ethernet),
  # use a broader rule that blocks all Docker bridge FORWARD traffic except
  # to local (RFC 1918) destinations and the VPN endpoint:
  #
  # iptables -I FORWARD -i docker0 ! -d 10.0.0.0/8 ! -d 172.16.0.0/12 ! -d 192.168.0.0/16 -p udp --dport 51820 -d <vpn_endpoint> -j ACCEPT
  # iptables -I FORWARD -i docker0 ! -d 10.0.0.0/8 ! -d 172.16.0.0/12 ! -d 192.168.0.0/16 -j DROP
  #
  # This variant allows Docker containers to reach local networks (for
  # inter-container comms) while blocking all internet egress except VPN.

  # ─── Persistent Secrets Directory (plaintext, no sops-nix/agenix) ───
  # Creates /etc/ghola/ at boot so the environment file is always readable.
  # Place the actual env file there manually after first boot:
  #   scp ghola_env CHANGE_ME_USERNAME@CHANGE_ME_HOSTNAME:/etc/ghola/env && chmod 600 /etc/ghola/env
  systemd.tmpfiles.rules = [
    "d /etc/ghola 0700 ${flakeSettings.username} users - -"
  ];
}
