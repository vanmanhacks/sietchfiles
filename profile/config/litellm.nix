{ ... }:

{
  services.litellm = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 7457;
    environment = { ANONYMIZED_TELEMETRY = "True"; };
  };
}
