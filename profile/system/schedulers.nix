{ lib, pkgs, ... }:

{

  #io-scheduler
  hardware.block.defaultScheduler = "kyber";
  hardware.block.defaultSchedulerRotational = "bfq";
  hardware.block.scheduler = {
    "mmcblk[0-9]*" = "bfq";
  };

  #lavd autopower scheduler
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
  };

}
