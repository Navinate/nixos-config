{ pkgs, ... }:
{
  # Crush — coding harness (Charmbracelet). No local provider is configured;
  # point it at external inference providers (OpenRouter via `ori`, etc.)
  # per https://charm.land/crush.json
  home.packages = [ pkgs.crush ];
}
