{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  # =========================================================================
  # Hyprland compositor
  # =========================================================================
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # ---- Vars ----
      "$mod"      = "SUPER";
      "$terminal" = "ghostty";
      "$launcher" = "hyprlauncher";
      "$browser"  = "zen";
      "$files"    = "ghostty -e yazi";

      # ---- Monitor ----
      # Auto-detect; tweak per real hardware later.
      monitor = [
        "DP-1, preferred, 0x0, 1"
        "HDMI-A-1, preferred, 2560x0, 1"
      ];

      # ---- Workspace preferences ----
      workspace = [
        "1, monitor:DP-1, default:true, persistent:true"
        "2, monitor:DP-1, persistent:true"
        "3, monitor:DP-1, persistent:true"
        "4, monitor:HDMI-A-1, default:true, persistent:true"
        "5, monitor:HDMI-A-1, persistent:true"
      ];

      # ---- Env vars inside the Hyprland session ----
      env = [
        # Uncomment these out when on virtual box
	      # "WLR_NO_HARDWARE_CURSORS,1"
        # "WLR_RENDERER_ALLOW_SOFTWARE,1"
	      # "LIBGL_ALWAYS_SOFTWARE,1"
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
      ];

      # ---- Autostart ----
      exec-once = [
        "hypridle"
        "waybar"
        "mako"
        "wl-paste --watch cliphist store"
      ];

      # ---- Look & feel ----
      # Animations OFF — VirtualBox software rendering can't keep up.
      # Flip `enabled = true` once on bare metal.
      animations.enabled = false;

      general = {
        gaps_in            = 5;
        gaps_out           = 5;
        border_size        = 2;
        "col.active_border"   = "rgb(${colors.mauve})";
        "col.inactive_border" = "rgb(${colors.surface0})";
        layout             = "dwindle";
        resize_on_border   = true;
      };

      decoration = {
        rounding = 6;
        # Effects off for VBox — too expensive in software.
        blur.enabled   = true;
        shadow.enabled = true;
      };

      input = {
        kb_layout      = "us";
        follow_mouse   = 1;
        sensitivity    = 0;
        touchpad.natural_scroll = true;
      };

      dwindle = {
        preserve_split   = true;
        pseudotile       = true;
      };

      misc = {
        disable_hyprland_logo    = true;
        disable_splash_rendering = true;
        force_default_wallpaper  = 0;
      };

      # ---- Keybinds ----
      bind =
        [
          # Apps
          "$mod, Return,       exec, $terminal"
          "$mod, B,            exec, $browser"
          "$mod, E,            exec, $files"
          "$mod, Space,        exec, $launcher"
          "$mod, L,            exec, hyprlock"
          # hyprshutdown isn't in nixpkgs 25.11 — quick wofi-based power menu instead
          ''$mod SHIFT, Escape, exec, echo -e "lock\nlogout\nreboot\nshutdown" | wofi --dmenu | xargs -I {} sh -c 'case {} in lock) hyprlock;; logout) hyprctl dispatch exit;; reboot) systemctl reboot;; shutdown) systemctl poweroff;; esac' ''
          "$mod, I,            exec, hyprsysteminfo"
          "$mod SHIFT, V,      exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

          # Screenshots
          ", Print,         exec, hyprshot -m region"
          "SHIFT, Print,    exec, hyprshot -m window"
          "CTRL, Print,     exec, hyprshot -m output"

          # Window mgmt
          "$mod, W,            killactive,"
          "$mod, F,            fullscreen,"
          "$mod, V,            togglefloating,"
          "$mod, P,            pseudo,"
          "$mod, J,            togglesplit,"

          # Focus
          "$mod, left,  movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up,    movefocus, u"
          "$mod, down,  movefocus, d"

          # Move windows
          "$mod SHIFT, left,  movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up,    movewindow, u"
          "$mod SHIFT, down,  movewindow, d"

          # Scratchpad
          "$mod, S,       togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          # Volume & brightness (no-ops in VBox, work on bare metal)
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessUp,   exec, brightnessctl s 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ]
        # Workspaces 1-9 + move-to
        ++ (builtins.concatLists (builtins.genList (i:
          let n = toString (i + 1); in [
            "$mod, ${n},        workspace,        ${n}"
            "$mod SHIFT, ${n},  movetoworkspace,  ${n}"
          ]
        ) 9));

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ---- Window rules ----
      windowrulev2 = [
        "float,class:(pavucontrol)"
        "float,class:(hyprsysteminfo)"
      ];
    };
  };

  # =========================================================================
  # hyprpaper — wallpaper daemon
  # =========================================================================
  # Drop a wallpaper file at ~/.config/hypr/wallpaper.jpg (or change the path).
  services.hyprpaper = {
    enable = true;
    settings = {
      preload   = [ "~/.config/hypr/wallpaper.jpg" ];
      wallpaper = [ ",~/.config/hypr/wallpaper.jpg" ];
      ipc       = "on";
    };
  };

  # =========================================================================
  # hyprlock — lock screen
  # =========================================================================
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor       = true;
        grace             = 2;
        disable_loading_bar = true;
      };

      background = [{
        path        = "screenshot";
        blur_passes = 0;   # blur off — VBox can't render it smoothly
        color       = "rgb(${colors.base})";
      }];

      input-field = [{
        size            = "300, 50";
        position        = "0, -80";
        halign          = "center";
        valign          = "center";
        outer_color     = "rgb(${colors.mauve})";
        inner_color     = "rgb(${colors.surface0})";
        font_color      = "rgb(${colors.text})";
        check_color     = "rgb(${colors.peach})";
        fail_color      = "rgb(${colors.red})";
        placeholder_text = "<i>password</i>";
        fade_on_empty   = false;
      }];

      label = [
        {
          text      = "$TIME";
          font_size = 64;
          color     = "rgb(${colors.text})";
          position  = "0, 120";
          halign    = "center";
          valign    = "center";
        }
        {
          text      = "Hi, $USER";
          font_size = 18;
          color     = "rgb(${colors.subtext0})";
          position  = "0, 40";
          halign    = "center";
          valign    = "center";
        }
      ];
    };
  };

  # =========================================================================
  # hypridle — idle daemon (auto-locks via hyprlock)
  # =========================================================================
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd       = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300;  on-timeout = "loginctl lock-session"; }
        { timeout = 600;  on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };
}
