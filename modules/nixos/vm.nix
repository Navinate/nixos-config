# VirtualBox guest tweaks.
# DELETE THIS FILE'S IMPORT from modules/nixos/default.nix when you move
# to bare metal — guest additions on real hardware will throw errors.
{
  virtualisation.virtualbox.guest = {
    enable = true;
    dragAndDrop = true;
    clipboard = true;
  };
}
