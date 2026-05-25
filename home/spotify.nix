{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      powerBar
      fullAlbumDate
      autoVolume
      coverAmbience
      aiBandBlocker
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
