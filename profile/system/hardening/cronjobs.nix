{ pkgs, ... }: {
  services.cron = {
    enable = true;
    # messages.enable = true;
    systemCronJobs = [
      # Every day at 2:00 AM, run clamscan as root and append output to a log file
      "0 2 * * * root ${pkgs.clamav}/bin/clamscan -r /home >> /var/log/clamscan.log"
      # Every day at 2:15 AM, run aide as root and append output to a log file
      #"0 2 * * * root ${pkgs.aide}/bin/aide"
    ];
  };
}

