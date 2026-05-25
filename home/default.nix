{ pkgs, ... }:
{
  imports = [
    ./theme.nix
    ./hyprland.nix
    ./waybar.nix
    ./ghostty.nix
    ./codium.nix
    ./firefox.nix
    ./zen.nix
    ./mako.nix
    ./darkman.nix
    ./claude-code.nix
    ./zed.nix
    ./spotify.nix
  ];

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    # Per-app enablement (catppuccin.enable = true would break on
    # editors like "antigravity" that don't exist in home-manager 25.11)
    ghostty.enable   = true;
    mako.enable      = true;
    waybar.enable    = true;
    hyprland.enable  = true;
    hyprlock = { enable = true; useDefaultConfig = false; };
    bat.enable       = true;
    fzf.enable       = true;
    eza.enable       = true;
    gtk.icon.enable  = true;
  };

  home.username = "kida";
  home.homeDirectory = "/home/kida";
  home.stateVersion = "25.11";

  # User-scope packages.
  # To remove one, just comment its line — no other file change needed.
  home.packages = with pkgs; [
    # --- Hypr ecosystem extras (not in their own home-manager modules) ---
    hyprlauncher    # app launcher (Super+Space)
    hyprshot        # screenshot (uses hyprshot -m region/window/output)
    # hyprshutdown  # NOT in nixpkgs 25.11 yet — uncomment after 26.05 or pull from unstable
    hyprsysteminfo  # GUI system-info tool
    hyprcursor      # cursor theme runtime (needs a hyprcursor theme to do anything visible)
    hyprpicker      # color picker — useful when theming

    # --- Wayland utilities ---
    wl-clipboard
    cliphist
    wofi             # used as the cliphist picker
    grim slurp       # backups in case hyprshot misbehaves
    brightnessctl
    playerctl
    pavucontrol      # GUI volume mixer

    # --- File manager + CLI utilities ---
    yazi
    xfce.thunar
    fastfetch
    htop
    ripgrep
    fd
    # bat, eza, fzf managed via programs.X below
    jq
    unzip

    # --- Development ---
    go
    nodejs_22
    nixd
    gh
    claude-code
    pnpm

    # --- General other stuff ---
    cameractrls-gtk4
    discord
    obsidian
    mission-center
    prismlauncher
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
