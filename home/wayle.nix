{ ... }:
{
  services.wayle = {
    enable = true;
    autoInstallDependencies = true;

    settings = {
      styling = {
        theme-provider = "wayle";
        # Wayle's built-in catppuccin-mocha palette, verbatim.
        palette = {
          bg       = "#11111b";
          surface  = "#181825";
          elevated = "#1e1e2e";
          fg       = "#cdd6f4";
          fg-muted = "#bac2de";
          primary  = "#b4befe";
          red      = "#f38ba8";
          yellow   = "#f9e2af";
          green    = "#a6e3a1";
          blue     = "#74c7ec";
        };
      };

      bar.layout = [
        {
          monitor = "*";
          left    = [ "hyprland-workspaces" ];
          center  = [ "clock" "notifications" ];
          right   = [ "cpu" "ram" "volume" "bluetooth" "network" "systray" ];
        }
      ];

      modules.clock.format = "%a %b %d  %H:%M";
    };
  };
}
