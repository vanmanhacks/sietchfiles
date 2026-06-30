{ lib, pkgs, ... }:

let
  prune-audit-logs = pkgs.writeShellScriptBin "prune-audit-logs" ''
    #!${pkgs.runtimeShell}
    
    # Define the log directory and how many days of logs to keep.
    LOG_DIR="/var/log/audit"
    DAYS_TO_KEEP=14

    # Log that we are starting the pruning process.
    # The `logger` command writes to the system journal.
    /usr/bin/logger "auditd: Disk space low. Pruning audit logs older than $DAYS_TO_KEEP days."

    # Find and delete archived audit logs (*.log.*) older than the specified time.
    # We are careful NOT to delete the active audit.log file.
    /usr/bin/find "$LOG_DIR" -name "audit.log.*" -mtime +"$DAYS_TO_KEEP" -delete

    /usr/bin/logger "auditd: Pruning complete."
  '';
  rulesFileContent = builtins.readFile ./audit.rules;
in
{
  security.auditd = {
    enable = lib.mkDefault true;
    settings = {
      space_left = 75;
      space_left_action = "exec ${prune-audit-logs}/bin/prune-audit-logs";
      admin_space_left = 50;
      admin_space_left_action = "exec ${prune-audit-logs}/bin/prune-audit-logs";
      disk_full_action = "suspend";
      disk_error_action = "syslog";
      max_log_file = 50;
      num_logs = 8;
      rate_limit = 2000;
      backlog_limit = 8192;
      max_log_file_action = "rotate";
    };
  };
  security.audit = {
    enable = lib.mkDefault true;
    rules =
      let
        lines = lib.strings.splitString "\n" rulesFileContent;
      in
      builtins.filter (line: (!lib.strings.hasPrefix "#" line) && line != "") lines;
  };
}
