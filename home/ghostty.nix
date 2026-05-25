{ ... }:
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
    };
  };
}
