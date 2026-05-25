{
  description = "Trey's NixOS + Hyprland test config";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
                # Import catppuccin with only the modules we use, avoiding
                # references to programs that don't exist in home-manager 25.11.
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
