{ config, pkgs, lib, ... }:

{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      neededForBoot = true;
    };

    "/nix" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

    "/persist" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [ "subvol=@persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

    "/persist/home" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

    "/persist/var/log" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "btrfs";
      options = [ "subvol=@log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };
  };

  # ==========================================
  # 1. AUTOMATED SCRUBBING (The "Doctor")
  # ==========================================
  # Periodically reads all data to verify checksums.
  # If it finds corruption (bit rot), it logs it (or fixes it if RAID1).
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly"; # "weekly" is okay too, but monthly is usually enough for laptops
    fileSystems = [ "/" ]; # Add "/home" if it's a separate partition
  };

  systemd.timers."btrfs-scrub-root".timerConfig = {
    Persistent = true;
    RandomizedDelaySec = "1h"; # Wait 1 hour after boot so it doesn't slow down startup
  };
  # Note: If you have a separate /home partition, you might need:
  # systemd.timers."btrfs-scrub-home".timerConfig = {
  #   Persistent = true;
  #   RandomizedDelaySec = "1h";
  # };

  # ==========================================
  # 2. AUTOMATED TRIM (SSD Health)
  # ==========================================
  # Crucial for NVMe/SSDs. Tells the drive which blocks are empty.
  # Prevents performance degradation over time.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ==========================================
  # 3. AUTOMATED BALANCING (Space Prevention)
  # ==========================================
  # NixOS does not have a native "autoBalance" option, so we make one.
  # This prevents the "Metadata Exhaustion" error that killed your server.
  # It gently reorganizes empty chunks (dusage=10) once a month.

  systemd.services.btrfs-balance = {
    description = "Btrfs Balance (Prevent Metadata Exhaustion)";
    serviceConfig = {
      Type = "oneshot";
      # Balance chunks that are < 10% full. Very fast, low impact.
      ExecStart = "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=10 -musage=10 /";
    };
  };

  systemd.timers.btrfs-balance = {
    description = "Run monthly Btrfs balance";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true; # Run immediately if laptop was off during the scheduled time
      RandomizedDelaySec = "1h"; # Don't run exactly at boot
    };
  };

  # ==========================================
  # 4. COMPRESSION (Performance & Space)
  # ==========================================
  # Ensure you are using ZSTD compression. It makes the disk faster 
  # (less data to write) and saves ~30% space.
  # Note: You usually set this in hardware-configuration.nix, 
  # but you can enforce it here for the root mount.
  # fileSystems."/".options = [ "compress=zstd" "noatime" ];
}

