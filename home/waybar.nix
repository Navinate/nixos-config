{ ... }:
{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer    = "top";
      position = "top";
      height   = 32;
      spacing  = 4;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "cpu" "memory" "pulseaudio" "network" "tray" ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      clock = {
        format = "{:%a %b %d  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = "CPU  {usage}%";
        interval = 2;
      };

      memory = {
        format = "MEM  {percentage}%";
        interval = 5;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "  muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      network = {
        format-wifi         = "  {essid}";
        format-ethernet     = "  {ipaddr}";
        format-disconnected = "  offline";
        tooltip-format      = "{ifname} via {gwaddr}";
      };

      tray.spacing = 10;
    };

    style = ''
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
  };
}
