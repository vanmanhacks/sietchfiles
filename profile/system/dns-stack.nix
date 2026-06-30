# /etc/nixos/dns-stack.nix
# Anonymized 3-tier DNS architecture template.
# Tier 1: Ad-blocking DNS filter → Tier 2: Caching resolver → Tier 3: Encrypted upstream
# Replace <PORT> placeholders with your deployment values.

{ config, pkgs, ... }:

{
  imports = [
    ./dns-aggregate.nix
  ];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 1048576;
    "net.core.wmem_max" = 4194304;
  };

  # ---------------------------------------------------------
  # Host Network Configuration
  # ---------------------------------------------------------

  # Disable systemd-resolved to prevent port conflicts with the DNS filter
  services.resolved.enable = false;

  # Force the server to use its own DNS stack for local resolution
  networking.nameservers = [ "127.0.0.1" ];

  # Prevent NetworkManager from overwriting resolv.conf with DHCP-provided DNS
  networking.networkmanager.dns = "none";
  networking.dhcpcd.extraConfig = "nohook resolv.conf";

  # ---------------------------------------------------------
  # Tier 1: Ad-Blocking DNS Filter
  # ---------------------------------------------------------
  services.adguardhome = {
    enable = true;
    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = <DNS_FILTER_PORT>;
        # Forward allowed traffic to the caching resolver
        upstream_dns = [ "127.0.0.1:<RESOLVER_PORT>" ];
        # Fallback bootstrap for initial resolution
        bootstrap_dns = [ "<BOOTSTRAP_DNS>" ];
        enable_dnssec = true;
      };
      http = {
        address = "0.0.0.0:<ADGUARD_UI_PORT>";
      };
      user_rules = import ./dns-regex.nix;
      filtering = {
        safe_fs_patterns = [ "/var/lib/adguard-blocklists/*" ];
      };
      filters = [
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard DNS filter"; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"; name = "Malicious URL Blocklist"; }
        { enabled = true; url = "/var/lib/adguard-blocklists/aggregated.txt"; name = "Aggregated Meta-Sinkhole"; }
      ];
    };
  };

  # ---------------------------------------------------------
  # Tier 2: Caching Resolver with DNSSEC Validation
  # ---------------------------------------------------------
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        port = <RESOLVER_PORT>;

        access-control = [ "127.0.0.0/8 allow" ];

        # Hardening & Performance
        do-not-query-localhost = "no";
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        harden-algo-downgrade = "yes";
        use-caps-for-id = "no";
        edns-buffer-size = 1232;
        prefetch = "yes";
        num-threads = 1;
        so-rcvbuf = "1m";

        # Privacy
        hide-identity = "yes";
        hide-version = "yes";
      };
      # Forward all queries to encrypted upstream proxy
      forward-zone = [
        {
          name = ".";
          forward-addr = [ "127.0.0.1@<DNSCRYPT_PORT>" ];
        }
      ];
    };
  };

  # ---------------------------------------------------------
  # Tier 3: Encrypted Upstream Transit
  # ---------------------------------------------------------
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:<DNSCRYPT_PORT>" ];

      require_dnssec = true;
      require_nolog = true;

      # Replace with your preferred upstream providers
      server_names = [ "<UPSTREAM_1>" "<UPSTREAM_2>" ];
    };
  };

  # ---------------------------------------------------------
  # VPN Overlay Network
  # ---------------------------------------------------------
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
