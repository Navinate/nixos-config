{ pkgs, ... }:
{
  # Modrinth bundles a generic, dynamically-linked JRE under
  # ~/.local/share/ModrinthApp (it requests /lib64/ld-linux-x86-64.so.2), which
  # NixOS cannot run out of the box ("Could not start dynamically linked
  # executable"). nix-ld provides a compatible dynamic loader plus the shared
  # libraries Java needs, letting that JRE actually execute.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    zlib
    stdenv.cc.cc.lib
    ncurses
    fontconfig
    freetype
    libGL
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXrandr
  ];
}
