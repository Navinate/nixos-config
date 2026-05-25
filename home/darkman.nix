{ pkgs, config, lib, ... }:
let
  palette = builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json");
  dark  = lib.mapAttrs (_: v: v.hex) palette.mocha.colors;
  light = lib.mapAttrs (_: v: v.hex) palette.latte.colors;

  # Waybar light-mode CSS (mirrors waybar.nix style but with Latte colors)
  waybarLightCss = ''
    @import "${config.catppuccin.sources.waybar}/latte.css";

    * {
      font-family: "FiraCode Nerd Font Ret", monospace;
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: @base;
      color: @text;
      border-bottom: 1px solid @surface0;
    }

    #workspaces button {
      padding: 0 8px;
      margin: 2px 2px;
      color: @subtext0;
      background: transparent;
      border-radius: 4px;
    }
    #workspaces button.active {
      color: @base;
      background: @mauve;
    }
    #workspaces button:hover {
      background: @surface0;
      color: @text;
    }

    #window { padding: 0 10px; color: @subtext1; }
    #clock,
    #cpu,
    #memory,
    #pulseaudio,
    #network,
    #tray {
      padding: 0 10px;
      margin: 2px 2px;
      background: @mantle;
      border-radius: 4px;
    }

    #cpu        { color: @peach; }
    #memory     { color: @green; }
    #pulseaudio { color: @blue; }
    #network    { color: @sapphire; }
  '';

  darkModeScript = pkgs.writeShellScript "dark-mode" ''
    # GTK
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"

    # Hyprland borders
    hyprctl keyword general:col.active_border "rgb(${builtins.substring 1 6 dark.mauve})"
    hyprctl keyword general:col.inactive_border "rgb(${builtins.substring 1 6 dark.surface0})"

    # Waybar — restart with default (dark) style
    pkill waybar || true
    sleep 0.3
    waybar &disown

    # Mako — restart with dark colors
    pkill mako || true
    sleep 0.2
    mako &disown
  '';

  lightModeScript = pkgs.writeShellScript "light-mode" ''
    # GTK
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"

    # Hyprland borders
    hyprctl keyword general:col.active_border "rgb(${builtins.substring 1 6 light.mauve})"
    hyprctl keyword general:col.inactive_border "rgb(${builtins.substring 1 6 light.surface0})"

    # Waybar — restart with light style
    pkill waybar || true
    sleep 0.3
    waybar -s ~/.config/waybar/style-light.css &disown

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

  # Light-mode waybar CSS (dark is the default from waybar.nix)
  home.file.".config/waybar/style-light.css".text = waybarLightCss;
}
