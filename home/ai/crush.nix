{ pkgs, ... }:
{
  # Crush — primary local-first coding harness (Charmbracelet).
  # opencode is kept installed (home/default.nix) as the fallback harness.
  #
  # Points at the local Ollama endpoint from modules/nixos/ollama.nix.
  # Config schema: https://charm.land/crush.json
  home.packages = [ pkgs.crush ];

  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";
    providers.ollama = {
      name = "Ollama (local)";
      base_url = "http://localhost:11434/v1/";
      type = "openai-compat";
      models = [
        {
          id = "qwen2.5-coder:7b";
          name = "Qwen2.5 Coder 7B";
          context_window = 32768;
          default_max_tokens = 8192;
        }
      ];
    };
  };
}
