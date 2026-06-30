{ lib, ... }:

{
  systemd.services.bluetooth.serviceConfig = {
    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectKernelLogs = true;
    ProtectHostname = true;
    ProtectControlGroups = true; 
    ProtectProc = "invisible";
    SystemCallFilter = [
      "~@obsolete"
      "~@cpu-emulation"
      "~@swap"
      "~@reboot"
      "~@mount"
    ];
    SystemCallArchitectures = "native";
  };
}
