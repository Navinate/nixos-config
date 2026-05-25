{ pkgs, ... }:
{
  # Pointer cursor
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # GTK appearance — the catppuccin GTK theme was archived upstream,
  # so Adwaita-dark remains the safest default. Icons are themed via
  # catppuccin.gtk.icon (enabled globally).
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  # Prefer dark mode in GNOME-style settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
