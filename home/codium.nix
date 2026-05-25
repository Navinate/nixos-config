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
        golang.go
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        jnoortheen.nix-ide
        astro-build.astro-vscode
      ];

      userSettings = {
        "window.autoDetectColorScheme" = true;
        "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
        "workbench.preferredLightColorTheme" = "Catppuccin Latte";
        "editor.fontFamily"    = "'FiraCode Nerd Font Retina', monospace";
        "editor.fontSize"      = 14;
        "editor.fontLigatures" = true;
        "editor.formatOnSave"  = true;
        "editor.minimap.enabled" = false;
        "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Retina'";
        "window.titleBarStyle" = "custom";
        "files.trimTrailingWhitespace" = true;

        "workbench.sideBar.location" = "right";
        "git.autofetch" = true;
        "git.confirmSync" = false;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
      };
    };
  };

  # Note: godot-tools (gdscript) isn't in pkgs.vscode-extensions yet.
  # Install it from the Open VSX marketplace inside Codium once you boot up,
  # OR add it later via marketplace fetcher.
}
