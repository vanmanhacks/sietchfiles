{
  systemd.services.tailscaled.serviceConfig = {
    # Tailscale is the most privileged daemon on the system — it creates TUN
    # interfaces, sets routes, manages iptables/nftables, and acts as an exit
    # node. Settings below are verified safe; anything more aggressive breaks
    # TUN creation, route setting, or WireGuard kernel operations.
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectProc = "invisible";
    PrivateTmp = true;
    PrivateMounts = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
    MemoryDenyWriteExecute = true;
    LockPersonality = true;
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    SystemCallFilter = [
      "~@mount"
      "~@swap"
      "~@clock"
      "~@debug"
      "~@module"
      "~@obsolete"
      "~@cpu-emulation"
      "~@privileged"
      "~@reboot"
      "~@raw-io"
    ];
    SystemCallArchitectures = "native";
    ReadWritePaths = [ "/var/lib/tailscale" ];

    # ponytail: NoNewPrivileges, ProtectKernelTunables, ProtectKernelModules,
    # PrivateDevices, and DevicePolicy=closed all break tailscaled.
    # tailscaled needs: TUN creation (no NoNewPrivileges), ip_forward sysctl
    # (no ProtectKernelTunables), WireGuard kernel module (no ProtectKernelModules),
    # and more /dev access than a closed policy with 4 devices provides.
  };
}
