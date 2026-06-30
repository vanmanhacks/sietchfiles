{ pkgs, ... }:

{
  systemd.services.honcho-mcp = {
    description = "Honcho MCP Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "docker.service" ];
    serviceConfig = {
      Type = "simple";
      User = "${flakeSettings.username}";
      WorkingDirectory = "/home/${flakeSettings.username}/Operations/AI-Agents/Hermes/Honcho/honcho/mcp";
      ExecStart = "${pkgs.wrangler}/bin/wrangler dev --port 8787 --ip 0.0.0.0";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
