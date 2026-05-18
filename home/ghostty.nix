{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  programs.ghostty = {
    enable = true;

    settings = {
      font-family = "FiraCode Nerd Font Ret";
      font-size = 12;

      window-padding-x = 8;
      window-padding-y = 8;
      confirm-close-surface = false;
      cursor-style-blink = false;
      scrollback-limit = 10000;

      background = "#${colors.base}";
      foreground = "#${colors.text}";
      cursor-color = "#${colors.rosewater}";
      cursor-text = "#${colors.base}";
      selection-background = "#${colors.surface2}";
      selection-foreground = "#${colors.text}";

      # Normal
      palette = [
        "0=#${colors.surface1}"
        "1=#${colors.red}"
        "2=#${colors.green}"
        "3=#${colors.yellow}"
        "4=#${colors.blue}"
        "5=#${colors.pink}"
        "6=#${colors.teal}"
        "7=#${colors.subtext1}"
        # Bright
        "8=#${colors.surface2}"
        "9=#${colors.red}"
        "10=#${colors.green}"
        "11=#${colors.yellow}"
        "12=#${colors.blue}"
        "13=#${colors.pink}"
        "14=#${colors.teal}"
        "15=#${colors.subtext0}"
      ];
    };
  };
}
