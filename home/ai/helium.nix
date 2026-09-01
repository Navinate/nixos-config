{ inputs, pkgs, ... }:
let
  heliumPkg = inputs.helium.defaultPackage.${pkgs.stdenv.hostPlatform.system};

  # The upstream AppImage enables Vulkan/ANGLE, which cannot create a GPU
  # surface on NVIDIA + Wayland, so the window renders nothing (invisible but
  # still clickable). Forcing software compositing makes it visible.
  helium = pkgs.symlinkJoin {
    name = "helium-wrapped";
    paths = [ heliumPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/helium --add-flags "--disable-gpu-compositing"
    '';
  };
in
{
  home.packages = [
    helium
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "application/xhtml+xml" = "helium.desktop";
      "application/pdf" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
    };
  };
}
