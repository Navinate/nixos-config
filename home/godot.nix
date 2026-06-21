{ pkgs, ... }:
{
  # Godot 4 (standard build, GDScript). Editor settings are managed by Godot
  # itself at runtime (~/.config/godot), so nothing is templated here.
  # See home/codium.nix for the pending GDScript LSP / external-editor wiring.
  home.packages = with pkgs; [
    godot
  ];
}
