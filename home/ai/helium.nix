{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.helium.defaultPackage.${pkgs.stdenv.hostPlatform.system}
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
