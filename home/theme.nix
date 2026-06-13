{ pkgs, config, ... }:
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
    # 26.05 changed gtk4.theme default to null; pin to gtk.theme to keep
    # current behavior (Adwaita-dark applied to GTK4 apps too).
    gtk4.theme = config.gtk.theme;
  };

  # Prefer dark mode in GNOME-style settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
