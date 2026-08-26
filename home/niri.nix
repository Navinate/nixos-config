{ pkgs, config, lib, ... }:
let
  palette = builtins.fromJSON (builtins.readFile "${config.catppuccin.sources.palette}/palette.json");
  colors = lib.mapAttrs (_: v: v.hex) palette.${config.catppuccin.flavor}.colors;
  swaylockColors = lib.mapAttrs (_: v: builtins.substring 1 6 v) colors;
  wallpaper = ../assets/totoro.jpg;
  niri = lib.getExe pkgs.niri;
  swaylockCommand = lib.concatStringsSep " " [
    (lib.getExe pkgs.swaylock)
    "--daemonize"
    "--color '${swaylockColors.base}'"
    "--inside-color '${swaylockColors.surface0}'"
    "--inside-clear-color '${swaylockColors.surface0}'"
    "--inside-ver-color '${swaylockColors.surface0}'"
    "--inside-wrong-color '${swaylockColors.surface0}'"
    "--ring-color '${swaylockColors.mauve}'"
    "--ring-clear-color '${swaylockColors.peach}'"
    "--ring-ver-color '${swaylockColors.mauve}'"
    "--ring-wrong-color '${swaylockColors.red}'"
    "--key-hl-color '${swaylockColors.peach}'"
    "--bs-hl-color '${swaylockColors.red}'"
    "--text-color '${swaylockColors.text}'"
    "--text-clear-color '${swaylockColors.text}'"
    "--text-ver-color '${swaylockColors.text}'"
    "--text-wrong-color '${swaylockColors.red}'"
  ];
in
{
  # This is a focused adaptation of Niri 26.04's default config. Keep custom
  # bindings here rather than relying on Niri defaults, which omit binds entirely.
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            numlock
        }

        touchpad {
            natural-scroll
        }
    }

    // Confirm these connector names and exact modes with `niri msg outputs`
    // after the first Niri login. They match the active Hyprland session.
    output "DP-1" {
        mode "2560x1440@164.983"
        scale 1
        position x=0 y=0
    }

    output "HDMI-A-1" {
        mode "2560x1440@143.933"
        scale 1
        position x=2560 y=0
    }

    layout {
        gaps 4
        center-focused-column "on-overflow"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        // Niri focus colors stay on the Mocha palette while darkman switches.
        focus-ring {
            width 2
            active-color "${colors.mauve}"
            inactive-color "${colors.surface0}"
        }

        border {
            off
        }

        shadow {
            on
            softness 20
            spread 2
            offset x=0 y=2
            color "#0007"
        }
    }

    workspace "1" { open-on-output "DP-1"; }
    workspace "2" { open-on-output "DP-1"; }
    workspace "3" { open-on-output "DP-1"; }
    workspace "4" { open-on-output "HDMI-A-1"; }
    workspace "5" { open-on-output "HDMI-A-1"; }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${lib.getExe pkgs.cliphist}" "store"
    spawn-at-startup "lxqt-policykit-agent"
    spawn-at-startup "blueman-applet"
    spawn-at-startup "${lib.getExe pkgs.swaybg}" "-i" "${wallpaper}" "-m" "fill"
    spawn-at-startup "${lib.getExe pkgs.xwayland-satellite}"

    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+B { spawn "helium"; }
        Mod+E { spawn "thunar"; }
        Mod+Space { spawn "rofi" "-show" "drun"; }
        Mod+L { spawn-sh "${swaylockCommand}"; }
        Mod+Shift+Escape { spawn "missioncenter"; }
        Mod+Ctrl+L { spawn-sh "choice=$(printf '%s\n' lock suspend logout reboot shutdown | rofi -dmenu -p Power); case \"$choice\" in lock) ${swaylockCommand};; suspend) systemctl suspend;; logout) ${niri} msg action quit;; reboot) systemctl reboot;; shutdown) systemctl poweroff;; esac"; }
        Mod+Shift+V { spawn-sh "${lib.getExe pkgs.cliphist} list | ${lib.getExe pkgs.rofi} -dmenu -p Clip | ${lib.getExe pkgs.cliphist} decode | ${pkgs.wl-clipboard}/bin/wl-copy"; }
        Mod+T { spawn "darkman" "toggle"; }

        Ctrl+Shift+S { screenshot; }
        Shift+Print { screenshot-window; }
        Ctrl+Print { screenshot-screen; }

        Mod+W repeat=false { close-window; }
        Mod+F { fullscreen-window; }
        Mod+V { toggle-window-floating; }
        Mod+P { toggle-column-tabbed-display; }
        Mod+J { consume-or-expel-window-right; }
        Mod+S { toggle-window-floating; }
        Mod+Shift+S { switch-focus-between-floating-and-tiling; }

        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }

        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }

        Mod+1 { focus-workspace "1"; }
        Mod+2 { focus-workspace "2"; }
        Mod+3 { focus-workspace "3"; }
        Mod+4 { focus-workspace "4"; }
        Mod+5 { focus-workspace "5"; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Shift+1 { move-column-to-workspace "1"; }
        Mod+Shift+2 { move-column-to-workspace "2"; }
        Mod+Shift+3 { move-column-to-workspace "3"; }
        Mod+Shift+4 { move-column-to-workspace "4"; }
        Mod+Shift+5 { move-column-to-workspace "5"; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "s" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "s" "5%-"; }
    }
  '';

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = swaylockCommand;
      }
      {
        timeout = 600;
        command = "${niri} msg action power-off-monitors";
      }
    ];
    events.before-sleep = swaylockCommand;
  };
}
