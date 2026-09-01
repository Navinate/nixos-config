{ pkgs, lib, osConfig, ... }:
let
  isHyprland = osConfig.my.desktop.compositor == "hyprland";
  isNiri = osConfig.my.desktop.compositor == "niri";
in
{
  imports = [
    ./theme.nix
    ./wayle.nix
    ./ghostty.nix
    ./codium.nix
    ./firefox.nix
    ./zen.nix
    ./darkman.nix
    ./zed.nix
    ./spotify.nix
    ./obsidian.nix
    ./rofi.nix
    ./godot.nix
    ./ai/default.nix
  ]
  ++ lib.optionals isHyprland [ ./hyprland.nix ]
  ++ lib.optionals isNiri [ ./niri.nix ];

  catppuccin = {
    enable     = true;
    autoEnable = true;
    flavor     = "mocha";
    accent     = "mauve";
  };

  home.username = "kida";
  home.homeDirectory = "/home/kida";
  home.stateVersion = "25.11";

  home.packages = with pkgs;
    [
      # --- Wayland utilities ---
      wl-clipboard
      cliphist
      grim slurp
      brightnessctl
      playerctl
      pavucontrol      # GUI volume mixer

      # --- File manager + CLI utilities ---
      fastfetch
      htop
      ripgrep
      fd
      # bat, eza, fzf managed via programs.X below
      jq
      unzip
      ouch

      # --- Development ---
      go
      nodejs_22
      nixd
      gh
      pnpm
      bun

      # --- General other stuff ---
      cameractrls-gtk4
      discord
      mission-center
      prismlauncher
      hey-mail
      ungoogled-chromium
      mixxx
      rpi-imager
    ]
    ++ lib.optionals isHyprland [
      hyprshot
      hyprshutdown
      hyprsysteminfo
      hyprcursor
      hyprpicker
      # Workaround: Modrinth (WebKitGTK) crashes under Wayland on Hyprland via
      # wp_linux_drm_syncobj. Disable WebKit's DMA-BUF renderer in this profile.
      (pkgs.symlinkJoin {
        name = "modrinth-app";
        paths = [ pkgs.modrinth-app ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm -f $out/bin/ModrinthApp
          makeWrapper ${pkgs.modrinth-app}/bin/ModrinthApp $out/bin/ModrinthApp \
            --set WEBKIT_DISABLE_DMABUF_RENDERER 1
        '';
      })
    ]
    ++ lib.optionals isNiri [
      modrinth-app
      swaylock
      swaybg
      xwayland-satellite
    ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -lah --git";
      ls = "eza";
      cat = "bat --plain";
      rebuild = "cd ~/nixos-config && just rebuild";
    };
  };

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "navinate";
      user.email = "treycluff@gmail.com";
    };
  };

}
