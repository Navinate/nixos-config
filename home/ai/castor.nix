{ pkgs, ... }:
let
  version = "1.4.1";
  goarch = {
    "x86_64-linux" = "amd64";
    "aarch64-linux" = "arm64";
  };
  hashes = {
    "x86_64-linux" = "48749bcf8ffc1b31bd5a997810987320f576f44d096f3469ae4d25a14f3780eb";
    "aarch64-linux" = "7e39131fcc4d88f605731c362bda9e58c4bd23704c4cbd03120374531565e170";
  };
  system = pkgs.stdenv.hostPlatform.system;

  castor = pkgs.stdenv.mkDerivation {
    pname = "castor";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/stupside/castor/releases/download/v${version}/castor_${version}_linux_${goarch.${system}}.tar.gz";
      sha256 = hashes.${system};
    };

    sourceRoot = ".";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 castor $out/bin/castor
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/castor \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.chromium
            pkgs.ffmpeg
          ]
        }
    '';

    meta.mainProgram = "castor";
  };
in
{
  home.packages = [ castor ];
}
