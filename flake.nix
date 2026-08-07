{
  description = "Trey's NixOS + Hyprland test config";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    helium.url = "github:FKouhai/helium2nix/main";
    herdr.url = "github:herdrdev/herdr/v0.8.0";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs: {
    nixosConfigurations.atlantis = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/atlantis/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
            users.kida = {
              imports = [
                ./home
                # Filter catppuccin modules to only the apps we want themed.
                # Importing all of them would auto-enable theming for rofi,
                # firefox, obsidian, etc., which clashes with our own configs.
                (nixpkgs.lib.modules.importApply
                  "${catppuccin}/modules/global.nix"
                  { catppuccinModules = map (m: "${catppuccin}/modules/home-manager/${m}") [
                      "ghostty.nix"
                      "mako.nix"
                      "waybar.nix"
                      "bat.nix"
                      "fzf.nix"
                      "eza.nix"
                      "gtk.nix"
                    ];
                  })
              ];
            };
          };
        }
      ];
    };
  };
}
