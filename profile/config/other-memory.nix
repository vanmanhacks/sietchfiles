{ config, pkgs, lib, ... }:

{
  # ─── Docker Compose Stack ───
  systemd.services.other-memory-stack = {
    description = "Other Memory — Self-Hosted Search & Crawl Stack";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "docker.service" ];
    requires = [ "docker.service" "other-memory-secret.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory";
      EnvironmentFile = "${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env";
      # Ensure config files are readable by the searxng container worker (non-root)
      ExecStartPre = [
        "${pkgs.coreutils}/bin/chmod 644 ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/searxng/settings.yml"
        "${pkgs.coreutils}/bin/chmod 644 ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/searxng/limiter.toml"
      ];
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };
  };

  # ─── Secret Generation ──────────────────────────────────────────────
  systemd.services.other-memory-secret = {
    description = "Generate Other Memory secrets";
    wantedBy = [ "other-memory-stack.service" ];
    before = [ "other-memory-stack.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "${flakeSettings.username}";
      # Create /etc/other-memory as root first, then demote to user for secret generation
      ExecStartPre = [
        "+${pkgs.coreutils}/bin/mkdir -p ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory"
      ];
      ExecStart = pkgs.writeShellScript "other-memory-secrets" ''
        set -euo pipefail

        if [ ! -f ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/searxng_secret ]; then
          ${pkgs.openssl}/bin/openssl rand -hex 32 > ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/searxng_secret
        fi

        if [ ! -f ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env ]; then
          touch ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env
          chmod 600 ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env
        fi

        if [ ! -f ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/crawl4ai_token ]; then
          ${pkgs.openssl}/bin/openssl rand -hex 16 > ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/crawl4ai_token
        fi

        if ! grep -q "^SEARXNG_SECRET=" ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env 2>/dev/null; then
          echo "SEARXNG_SECRET=$(cat ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/searxng_secret)" >> ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env
        fi

        if ! grep -q "^CRAWL4AI_TOKEN=" ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env 2>/dev/null; then
          echo "CRAWL4AI_TOKEN=$(cat ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/crawl4ai_token)" >> ${config.users.users.${flakeSettings.username}.home}/Operations/GHOLA-OM/other-memory/env
        fi
      '';
    };
  };
}
