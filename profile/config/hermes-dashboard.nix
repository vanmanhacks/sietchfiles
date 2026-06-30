{ pkgs, inputs, ... }:

{
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "tailscaled.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      User = "${flakeSettings.username}";
      Group = "users";
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = "/home/${flakeSettings.username}/Operations/AI-Agents/agent-workspace";
      ExecStart = "${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent}/bin/hermes dashboard --no-open --host <TAILSCALE_IP> --port 9119 --insecure";
    };
  };
}
