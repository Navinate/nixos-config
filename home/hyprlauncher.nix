{ pkgs, config, lib, ... }:
let
  palette = builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json");
  c = lib.mapAttrs (_: v: builtins.substring 1 6 v.hex) palette.${config.catppuccin.flavor}.colors;
  # hyprtoolkit wants colors as 0xAARRGGBB ints
  argb = a: hex: "0x${a}${hex}";
in
{
  # =========================================================================
  # hyprtoolkit theme — the single, global config for *every* hyprtoolkit app.
  # Today that's just hyprlauncher; any future hyprtoolkit app inherits this.
  # =========================================================================
  xdg.configFile."hypr/hyprtoolkit.conf".text = ''
    # Catppuccin ${config.catppuccin.flavor}. Backgrounds are ~95% opaque so
    # Hyprland's blur turns them into frosted glass.
    background       = ${argb "f2" c.crust}
    base             = ${argb "f2" c.base}
    alternate_base   = ${argb "ff" c.surface0}
    text             = ${argb "ff" c.text}
    bright_text      = ${argb "ff" c.lavender}
    link_text        = ${argb "ff" c.sky}
    accent           = ${argb "ff" c.mauve}
    accent_secondary = ${argb "ff" c.pink}

    rounding_large = 16
    rounding_small = 10

    font_family           = FiraCode Nerd Font
    font_family_monospace = FiraCode Nerd Font Mono
    h1_size               = 22
    h2_size               = 16
    h3_size               = 14
    font_size             = 13
    small_font_size       = 11

    icon_theme = Papirus-Dark
  '';

  # =========================================================================
  # hyprlauncher — Spotlight/Raycast-style behaviour
  # =========================================================================
  xdg.configFile."hyprlauncher/hyprlauncher.conf".text = ''
    general {
        grab_focus = 1
    }

    ui {
        window_size = 720, 450
    }

    finders {
        desktop_icons    = 1
        desktop_terminal = ghostty
        math_prefix      = =
        unicode_prefix   = .
    }
  '';

  # =========================================================================
  # Pick up newly-installed apps without a relogin.
  #
  # hyprlauncher runs as a persistent daemon and inotify-watches the *resolved*
  # app dirs — which on NixOS are immutable /nix/store paths. A rebuild swaps
  # the /etc/profiles symlink instead of touching that dir, so the watch never
  # fires and the daemon serves a stale list until restart. Killing it on each
  # switch makes the next Super+Space spawn a fresh daemon that rescans.
  # =========================================================================
  home.activation.refreshHyprlauncher =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.procps}/bin/pkill -x hyprlauncher || true
    '';
}
