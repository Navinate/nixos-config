{ pkgs, ... }:
{
  # Enable Hyprland at the system level (registers a session for the DM)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # PAM for hyprlock — without this, hyprlock cannot authenticate
  security.pam.services.hyprlock = { };

  # Polkit for elevation prompts
  security.polkit.enable = true;

  # Session vars
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Hint Electron apps to use Wayland
    # --- VirtualBox software-rendering fallback ---
    # Remove these once you're on bare metal.
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  # XDG portals (file pickers, screen sharing, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Greetd display manager with tuigreet (lightweight TUI greeter)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # System-wide fonts (used by waybar, ghostty, etc.)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];

  # dconf — needed by some GTK apps
  programs.dconf.enable = true;
}
