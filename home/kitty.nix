{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      window_padding_width   = 8;
      confirm_os_window_close = 0;
      enable_audio_bell      = false;
      cursor_blink_interval  = 0;
      scrollback_lines       = 10000;

      # Catppuccin Mocha
      background          = "#${colors.base}";
      foreground          = "#${colors.text}";
      cursor              = "#${colors.rosewater}";
      cursor_text_color   = "#${colors.base}";
      selection_background = "#${colors.surface2}";
      selection_foreground = "#${colors.text}";

      # Normal
      color0  = "#${colors.surface1}";
      color1  = "#${colors.red}";
      color2  = "#${colors.green}";
      color3  = "#${colors.yellow}";
      color4  = "#${colors.blue}";
      color5  = "#${colors.pink}";
      color6  = "#${colors.teal}";
      color7  = "#${colors.subtext1}";
      # Bright
      color8  = "#${colors.surface2}";
      color9  = "#${colors.red}";
      color10 = "#${colors.green}";
      color11 = "#${colors.yellow}";
      color12 = "#${colors.blue}";
      color13 = "#${colors.pink}";
      color14 = "#${colors.teal}";
      color15 = "#${colors.subtext0}";
    };
  };
}
