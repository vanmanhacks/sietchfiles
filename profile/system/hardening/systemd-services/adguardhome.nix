{
  systemd.services.adguardhome.serviceConfig = {
    MemoryDenyWriteExecute = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
  };
}
