{ pkgs, ... }:
{
  # Pointer cursor — applied to both Wayland and XWayland apps.
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # GTK appearance. Adwaita-dark is the safest default; swap for a Catppuccin
  # GTK theme later if you want (e.g. `magnetic-catppuccin-gtk`).
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Prefer dark mode in GNOME-style settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
