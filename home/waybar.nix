{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
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
        format = "  {usage}%";
        interval = 2;
      };

      memory = {
        format = "  {percentage}%";
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
        background: #${colors.base};
        color: #${colors.text};
        border-bottom: 1px solid #${colors.surface0};
      }

      #workspaces button {
        padding: 0 8px;
        margin: 2px 2px;
        color: #${colors.subtext0};
        background: transparent;
        border-radius: 4px;
      }
      #workspaces button.active {
        color: #${colors.base};
        background: #${colors.mauve};
      }
      #workspaces button:hover {
        background: #${colors.surface0};
        color: #${colors.text};
      }

      #window { padding: 0 10px; color: #${colors.subtext1}; }
      #clock,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #tray {
        padding: 0 10px;
        margin: 2px 2px;
        background: #${colors.mantle};
        border-radius: 4px;
      }

      #cpu        { color: #${colors.peach}; }
      #memory     { color: #${colors.green}; }
      #pulseaudio { color: #${colors.blue}; }
      #network    { color: #${colors.sapphire}; }
    '';
  };
}
