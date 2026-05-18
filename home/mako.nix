{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  services.mako = {
    enable = true;
    settings = {
      font             = "JetBrainsMono Nerd Font 11";
      background-color = "#${colors.base}";
      text-color       = "#${colors.text}";
      border-color     = "#${colors.mauve}";
      border-size      = 2;
      border-radius    = 6;
      padding          = "10";
      default-timeout  = 5000;
      max-icon-size    = 32;
      anchor           = "top-right";

      "urgency=high" = {
        border-color    = "#${colors.red}";
        default-timeout = 0;
      };
    };
  };
}
