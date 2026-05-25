{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      font             = "FiraCode Nerd Font Ret 11";
      border-size      = 2;
      border-radius    = 6;
      padding          = "10";
      default-timeout  = 5000;
      max-icon-size    = 32;
      anchor           = "top-right";

      "urgency=high" = {
        default-timeout = 0;
      };
    };
  };
}
