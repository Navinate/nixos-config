{ config, lib, pkgs, ... }:
let
  isHyprland = config.my.desktop.compositor == "hyprland";
  isNiri = config.my.desktop.compositor == "niri";
  sessionCommand =
    if isHyprland then
      "${pkgs.hyprland}/bin/start-hyprland"
    else
      "${pkgs.niri}/bin/niri-session";
in
{
  programs = {
    hyprland = lib.mkIf isHyprland {
      enable = true;
      xwayland.enable = true;
    };
    niri.enable = isNiri;

    # Needed by GTK applications regardless of compositor.
    dconf.enable = true;
  };

  security = {
    # Polkit for elevation prompts.
    polkit.enable = true;

    # hyprlock is only installed by the Hyprland profile.
    pam.services.hyprlock = lib.mkIf isHyprland { };
  };

  environment.sessionVariables = {
    # Hint Electron applications to use Wayland. Do not set GDK_BACKEND
    # globally: it prevents Niri's screencast portal from working correctly.
    NIXOS_OZONE_WL = "1";
  };

  # Both profiles need portals. Niri's NixOS module adds its gnome portal;
  # Hyprland keeps the GTK portal it used before this selector existed.
  xdg.portal = {
    enable = true;
    extraPortals = lib.mkIf isHyprland [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Greetd launches the selected profile directly. Niri must use niri-session
  # so it can import the graphical session environment into systemd-user.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${sessionCommand}";
      user = "greeter";
    };
  };

  # System-wide fonts used by the shell and applications.
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];
}
