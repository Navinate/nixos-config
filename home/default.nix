{ pkgs, ... }:
{
  imports = [
    ./theme.nix
    ./hyprland.nix
    ./wayle.nix
    ./ghostty.nix
    ./codium.nix
    ./firefox.nix
    ./zen.nix
    ./darkman.nix
    ./claude-code.nix
    ./pi.nix
    ./crush.nix
    ./zed.nix
    ./spotify.nix
    ./obsidian.nix
    ./rofi.nix
  ];

  catppuccin = {
    enable     = true;
    autoEnable = true;
    flavor     = "mocha";
    accent     = "mauve";
  };

  home.username = "kida";
  home.homeDirectory = "/home/kida";
  home.stateVersion = "25.11";

  # User-scope packages.
  # To remove one, just comment its line — no other file change needed.
  home.packages = with pkgs; [
    # --- Hypr ecosystem extras (not in their own home-manager modules) ---
    hyprshot        # screenshot (uses hyprshot -m region/window/output)
    hyprshutdown    # power menu (lock/logout/reboot/shutdown)
    hyprsysteminfo  # GUI system-info tool
    hyprcursor      # cursor theme runtime (needs a hyprcursor theme to do anything visible)
    hyprpicker      # color picker — useful when theming

    # --- Wayland utilities ---
    wl-clipboard
    cliphist
    grim slurp       # backups in case hyprshot misbehaves
    brightnessctl
    playerctl
    pavucontrol      # GUI volume mixer

    # --- File manager + CLI utilities ---
    thunar
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
    opencode        # fallback local-first coding harness (primary is crush, see home/crush.nix)

    # --- General other stuff ---
    cameractrls-gtk4
    discord
    mission-center
    prismlauncher
    hey-mail
    ungoogled-chromium
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
