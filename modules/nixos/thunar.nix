{ pkgs, ... }:
{
  # Thunar file manager with removable-media support
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-volman ];
  };

  # Mounting removable drives without root, plus sidebar volume list
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
