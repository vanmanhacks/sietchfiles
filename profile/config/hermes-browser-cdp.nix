{ config, pkgs, lib, ... }:

{
  # ─── Hermes Browser Bridge — Persistent CDP via Chromium ───
  #
  # Provides an always-running Chromium instance with remote debugging on
  # 127.0.0.1:9222. Hermes Agent connects via Chrome DevTools Protocol.
  #
  # DEPLOY:
  #   1. imports = [ ./hermes-browser-cdp.nix ];
  #   2. sudo nixos-rebuild switch
  #   3. systemctl --user start hermes-browser-cdp
  #
  # AUTO-RECOGNITION (Hermes side):
  #   hermes config set browser.cdp_url http://127.0.0.1:9222
  #
  #   Hermes checks this endpoint at session start. If reachable, all
  #   browser tools (browser_navigate, browser_click, browser_snapshot, …)
  #   become available automatically — no /browser connect needed.
  #
  #   To verify: hermes tools list | grep browser_navigate
  #
  # STEALTH NOTE:
  #   This is headless Chromium on your real IP. Browserbase (cloud) is the
  #   stealth option. For JS-rendered crawling without fingerprint concerns,
  #   use Other Memory's web_crawl (Crawl4ai) instead.

  systemd.user.services.hermes-browser-cdp = {
    description = "Chromium CDP bridge for Hermes Agent browser tools";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      # StateDirectory creates ~/.local/state/hermes-browser-cdp — persists
      # across reboots so saved credentials, cookies, and sessions survive.
      # (RuntimeDirectory would be /run/user/$UID — wiped every boot.)
      StateDirectory = "hermes-browser-cdp";
      StateDirectoryMode = "0700";

      # Single-line ExecStart — multi-line continuation can break in NixOS-generated units.
      # chromium's wrapper script injects GTK/Wayland libs via LD_LIBRARY_PATH;
      # on a headless system without $DISPLAY this is harmless if --headless is passed.
      ExecStart = "${pkgs.chromium}/bin/chromium --headless --remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --disable-gpu --disable-dev-shm-usage --disable-background-networking --disable-sync --no-first-run --no-default-browser-check --user-data-dir=%S/hermes-browser-cdp";

      Restart = "on-failure";
      RestartSec = "5s";

      # Sandboxing — Chromium-compatible. Avoid ProtectSystem=strict/ProtectHome
      # which break Crashpad init (SIGTRAP in PlatformCrashpadInitialization).
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
      # Allow Chromium to manage its own subprocess sandbox
      RestrictNamespaces = false;
    };
  };
}
