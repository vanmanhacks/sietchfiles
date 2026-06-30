{ config, pkgs, inputs, flakeSettings, ... }:

{

  networking.hostName = flakeSettings.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  services.tor = {
    enable = true;
    settings = {
      SOCKSPort = [ 9050 ];
      DNSPort = [ 9053 ];
      AutomapHostsOnResolve = true;
      AutomapHostsSuffixes = [ ".onion" ".exit" ];
      ExitRelay = false;
      ExitPolicy = [ "reject *:*" ];
      BandwidthRate = "1 MB";
      BandwidthBurst = "2 MB";
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # systemd.network.networks."10-wlan" = {
  #   matchConfig.Name = "wlp1s0";
  #   address = [
  #     "192.168.1.231/24"
  #   ];
  #   routes = [
  #     { Gateway = "fe80::1"; }
  #     { Gateway = "192.168.1.1"; }
  #   ];
  #   linkConfig.RequiredForOnline = "routable";
  # };
  #  networking.firewall = {
  #    enable = true;
  #    extraCommands =
  #    ''
  #       iptables -A DOCKER-USER -m physdev
  #       iptables -A DOCKER-USER -i br-+ -o br-+ -j DROP
  #    '';
  #  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}
