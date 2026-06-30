{
  config,
  pkgs,
  lib,
  flakeSettings,
  ...
}: 
let
  inherit (lib) mkIf;
  cfg = config.custom.security.usbguard;
in {
  options.custom.security.usbguard = {
    enable = lib.mkEnableOption "usbguard";
  };

  config = mkIf cfg.enable {
    services.usbguard = {
      enable = true;
      IPCAllowedUsers = ["root" "${flakeSettings.username}"];
      presentDevicePolicy = "allow";
      rules = ''
        # USB root hubs (internal — must be allowed)
        allow id 1d6b:0002  # USB 2.0 root hub
        allow id 1d6b:0003  # USB 3.0 root hub
        # Peripherals
        allow id 3938:1296  # onn Gaming Keyboard
        allow id 0bda:8812  # RTL8812AU WiFi adapter — monitor mode + packet injection
      '';
      ruleFile = "/var/lib/usbguard/usbguard-rules.conf";
    };

    environment.systemPackages = [pkgs.usbguard];
  };
}

