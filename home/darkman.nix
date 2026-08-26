{ pkgs, config, lib, osConfig, ... }:
let
  palette = builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json");
  dark  = lib.mapAttrs (_: v: v.hex) palette.mocha.colors;
  light = lib.mapAttrs (_: v: v.hex) palette.latte.colors;
  isHyprland = osConfig.my.desktop.compositor == "hyprland";

  darkModeScript = pkgs.writeShellScript "dark-mode" ''
    # GTK
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"

    ${lib.optionalString isHyprland ''
      # Hyprland borders
      hyprctl keyword general:col.active_border "rgb(${builtins.substring 1 6 dark.mauve})"
      hyprctl keyword general:col.inactive_border "rgb(${builtins.substring 1 6 dark.surface0})"
    ''}

    # Wayle is managed as a graphical-session service.
    ${pkgs.systemd}/bin/systemctl --user restart wayle.service || true

    # Mako — restart with dark colors
    pkill mako || true
    sleep 0.2
    mako &disown
  '';

  lightModeScript = pkgs.writeShellScript "light-mode" ''
    # GTK
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"

    ${lib.optionalString isHyprland ''
      # Hyprland borders
      hyprctl keyword general:col.active_border "rgb(${builtins.substring 1 6 light.mauve})"
      hyprctl keyword general:col.inactive_border "rgb(${builtins.substring 1 6 light.surface0})"
    ''}

    # Wayle is managed as a graphical-session service.
    ${pkgs.systemd}/bin/systemctl --user restart wayle.service || true

    # Mako — restart with light colors
    pkill mako || true
    sleep 0.2
    mako \
      --background-color="${light.base}" \
      --text-color="${light.text}" \
      --border-color="${light.mauve}" \
      &disown
  '';
in
{
  # Darkman service
  services.darkman = {
    enable = true;
    settings = {
      usegeoclue = false;
    };
  };

  # Place transition scripts where darkman discovers them
  home.file.".local/share/dark-mode.d/theme.sh" = {
    source = darkModeScript;
    executable = true;
  };
  home.file.".local/share/light-mode.d/theme.sh" = {
    source = lightModeScript;
    executable = true;
  };

}
