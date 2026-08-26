{ config, lib, ... }:
{
  options.my.desktop.compositor = lib.mkOption {
    type = lib.types.enum [
      "hyprland"
      "niri"
    ];
    default = "hyprland";
    description = "Wayland compositor profile enabled for this host.";
  };

  config.assertions = [
    {
      assertion = lib.elem config.my.desktop.compositor [ "hyprland" "niri" ];
      message = "my.desktop.compositor must be either \"hyprland\" or \"niri\".";
    }
  ];
}
