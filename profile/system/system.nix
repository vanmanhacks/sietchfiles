{ lib, ... }:

{
  # Nix Settings
  nix.settings = { download-buffer-size = 524288000; };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  programs.dconf.enable = true;

  # TPM2 disabled on this host — lanzaboote handles Secure Boot independently.
  # To re-enable: uncomment security.tpm2.enable and add user to tss group.

  # Bootloader
  # boot.loader.grub = {
  #   efiSupport = true;
  #   # efiInstallAsRemovable = true;
  #   device = "/dev/sda";
  # };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
