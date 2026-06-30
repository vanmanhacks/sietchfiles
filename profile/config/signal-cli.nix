{ pkgs, ... }:

{
  systemd.services.signal-cli = {
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.signal-cli-unstable}/bin/signal-cli --account +1NNN-NNN-NNNN daemon --http 127.0.0.1:8181";
    serviceConfig = {
      User = "${flakeSettings.username}";
      # Restart = "on-failure";
    };
  };
}
