{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default = {
      # Extensions from nixpkgs. To add more, search:
      #   nix-shell -p nix-search-cli --run 'nix-search vscode-extensions.PUBLISHER'
      # Or fetch from marketplace at activation time (slower but always current).
      extensions = with pkgs.vscode-extensions; [
        # Themes / appearance
        catppuccin.catppuccin-vsc
        # Languages you mentioned: go, js, gdscript
        golang.go
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        # Nix support — you'll want this
        jnoortheen.nix-ide
      ];

      userSettings = {
        "workbench.colorTheme" = "Catppuccin Mocha";
        "editor.fontFamily"    = "'FiraCode Nerd Font Ret', monospace";
        "editor.fontSize"      = 14;
        "editor.fontLigatures" = true;
        "editor.formatOnSave"  = true;
        "editor.minimap.enabled" = false;
        "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Ret'";
        "window.titleBarStyle" = "custom";
        "files.trimTrailingWhitespace" = true;
        # Use Wayland for Codium (smoother on Hyprland)
        "window.systemColorTheme" = "dark";

        "workbench.sideBar.location": "right";
      };
    };
  };

  # Note: godot-tools (gdscript) isn't in pkgs.vscode-extensions yet.
  # Install it from the Open VSX marketplace inside Codium once you boot up,
  # OR add it later via marketplace fetcher.
}
