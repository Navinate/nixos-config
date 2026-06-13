{ pkgs, config, lib, ... }:
let
  palette = builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json");
  c = lib.mapAttrs (_: v: builtins.substring 1 6 v.hex) palette.${config.catppuccin.flavor}.colors;
in
{
  # =========================================================================
  # rofi — Spotlight-style launcher (Super+Space), also used for the
  # cliphist picker and power menu. Colors come from the catppuccin
  # palette JSON directly, matching the pattern used by hyprland.nix.
  # =========================================================================
  programs.rofi = {
    enable   = true;
    package  = pkgs.rofi;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    font     = "FiraCode Nerd Font 13";

    extraConfig = {
      modes               = "drun,run";
      show-icons          = true;
      icon-theme          = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun        = "";
      display-run         = "";
      kb-cancel           = "Escape";
      sidebar-mode        = false;
    };

    theme = toString (pkgs.writeText "spotlight.rasi" ''
      * {
        bg:       #${c.crust}F2;
        bg-alt:   #${c.surface0}FF;
        fg:       #${c.text}FF;
        fg-muted: #${c.subtext0}FF;
        accent:   #${c.mauve}FF;

        background-color: transparent;
        text-color:       @fg;
        font:             "FiraCode Nerd Font 13";
      }

      window {
        transparency:     "real";
        location:         center;
        anchor:           center;
        width:            720px;
        height:           450px;
        border-radius:    16px;
        background-color: @bg;
        padding:          0;
      }

      mainbox {
        children:         [ inputbar, listview ];
        padding:          12px;
        spacing:          8px;
        background-color: transparent;
      }

      inputbar {
        children:         [ entry ];
        padding:          10px 14px;
        background-color: @bg-alt;
        border-radius:    10px;
      }

      entry {
        placeholder:       "Search…";
        placeholder-color: @fg-muted;
        text-color:        @fg;
      }

      listview {
        columns:          1;
        lines:            8;
        spacing:          4px;
        padding:          4px 0;
        scrollbar:        false;
        fixed-height:     false;
        background-color: transparent;
      }

      element {
        padding:          8px 12px;
        spacing:          10px;
        border-radius:    10px;
        background-color: transparent;
        text-color:       @fg;
      }

      element selected {
        background-color: @accent;
        text-color:       @bg;
      }

      element-icon {
        size:             24px;
        background-color: transparent;
      }

      element-text {
        background-color: transparent;
        text-color:       inherit;
        vertical-align:   0.5;
      }
    '');
  };
}
