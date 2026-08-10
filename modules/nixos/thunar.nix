{ pkgs, ... }:
{
  # Thunar file manager with removable-media support
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-volman ];
  };

  # Mounting removable drives without root, plus sidebar volume list
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
