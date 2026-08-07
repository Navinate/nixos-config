{ pkgs, ... }:
let
  version = "0.5.0";
  rev = "f2a1c31";
  system = pkgs.stdenv.hostPlatform.system;
  hashes = {
    "x86_64-linux" = "9cc0e920f5e8be7b8170e35293a7676a61364d74dd7ef43e47cbd0cdc63879a8";
  };

  ori = pkgs.stdenv.mkDerivation {
    pname = "ori";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/OpenRouterLabs/ori-releases/releases/download/cli-${version}-${rev}/ori-linux-x64";
      sha256 = hashes.${system};
    };

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    installPhase = ''
      install -Dm755 $src $out/bin/ori
    '';
  };
in
{
  home.packages = [ ori ];
}