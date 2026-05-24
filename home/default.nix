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
    ./claude-code.nix
  ];

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
    pavucontrol      # GUI volume mixer for waybar click

    # --- File manager + CLI utilities ---
    yazi
    fastfetch
    htop
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    unzip
    gparted

    # --- Languages (add as needed) ---
    go
    nodejs_22
    nixd
    # godot_4  # uncomment when you want gdscript work

    # --- AI stuff ---
    claude-code

    # --- General other stuff ---
    discord
    spotify
    obsidian
    mission-center
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

  programs.git = {
    enable = true;
    settings = {
      user.name = "navinate";
      user.email = "treycluff@gmail.com";
    };
  };
}
