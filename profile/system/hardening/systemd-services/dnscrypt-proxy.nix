{
  systemd.services.dnscrypt-proxy.serviceConfig = {
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectProc = "invisible";
    PrivateDevices = true;
    PrivateMounts = true;
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  };
}
