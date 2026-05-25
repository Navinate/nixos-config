{ lib, pkgs, ... }:
let
  # Obsidian has no home-manager module, so we manage the package + theme files
  # directly. Theme files are read-only from Obsidian's side, so symlinking them
  # into the Nix store is safe (unlike appearance.json, which Obsidian rewrites).
  catppuccinTheme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "obsidian";
    rev = "2.0.3";
    hash = "sha256-9fSFj9Tzc2aN9zpG5CyDMngVcwYEppf7MF1ZPUWFyz4=";
  };
in
{
  home.packages = [ pkgs.obsidian ];

  # Install the Catppuccin theme into the vault. Obsidian needs theme.css +
  # manifest.json side by side under .obsidian/themes/<name>/.
  home.file."Notes/.obsidian/themes/Catppuccin/theme.css".source =
    "${catppuccinTheme}/theme.css";
  home.file."Notes/.obsidian/themes/Catppuccin/manifest.json".source =
    "${catppuccinTheme}/manifest.json";

  # Select the theme by merging into appearance.json rather than symlinking it,
  # so the GUI can still write other appearance settings (font, etc.).
  # "theme":"obsidian" = dark base scheme, which Catppuccin renders as Mocha.
  home.activation.obsidianCatppuccin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    appearance="$HOME/Notes/.obsidian/appearance.json"
    run mkdir -p "$(dirname "$appearance")"
    if [ ! -e "$appearance" ]; then
      run cp ${pkgs.writeText "appearance.json" (builtins.toJSON {
        cssTheme = "Catppuccin";
        theme = "obsidian";
      })} "$appearance"
      run chmod u+w "$appearance"
    else
      tmp="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.jq}/bin/jq '.cssTheme = "Catppuccin" | .theme = "obsidian"' "$appearance" > "$tmp"
      run mv "$tmp" "$appearance"
    fi
  '';
}
