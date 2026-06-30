# /etc/nixos/firewall.nix
# Anonymized — replace <PORT> placeholders with your deployment values.

{ config, ... }: {
  networking.firewall = {
    enable = true;
    logRefusedPackets = true;
    logRefusedConnections = true;

    # Trusted interfaces
    trustedInterfaces = [ "<VPN_INTERFACE>" ];

    # Global ports — open to all interfaces
    allowedTCPPorts = [ <SSH_PORT> <DNS_PORT> <ADGUARD_UI_PORT> <DASHBOARD_PORT> ];
    allowedUDPPorts = [ <DNS_PORT> <TAILSCALE_QUIC_PORT> config.services.tailscale.port ];

    # VPN interface-specific — accessible only via overlay network
    interfaces."<VPN_INTERFACE>" = {
      allowedTCPPorts = [ <SSH_PORT> <ALT_PORT> <DASHBOARD_PORT> ];
      allowedUDPPorts = [ <DNS_PORT> <TAILSCALE_QUIC_PORT> ];
    };

    # VPN tunnel — all ports trusted (outbound VPN)
    interfaces."<TUN_INTERFACE>" = {
      allowedTCPPortRanges = [{ from = 0; to = 65535; }];
      allowedUDPPortRanges = [{ from = 0; to = 65535; }];
    };
  };
}
