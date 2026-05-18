{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Identity
  networking.hostName = "nixtest";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console keymap
  console.keyMap = "us";

  # User
  users.users.trey = {
    isNormalUser = true;
    description = "Trey";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };

  # Allow unfree (vscodium, etc.)
  nixpkgs.config.allowUnfree = true;

  # Minimal base system packages — most user tooling lives in home/
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    just
  ];

  # Enable flakes + new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto-optimize the store
  nix.settings.auto-optimise-store = true;

  # Don't change this lightly — see release notes
  system.stateVersion = "25.11";
}
