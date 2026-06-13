{ pkgs, ... }:
{
  # Local LLM serving. Exposes an OpenAI-compatible API on 127.0.0.1:11434
  # that the Crush harness (home/crush.nix) points at.
  #
  # NOTE: requires a reboot after any NVIDIA driver change — a live driver/
  # library mismatch breaks CUDA inference (nvidia-smi will also fail).
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # RTX 3080, compute 8.6

    # Pulled at activation. qwen2.5-coder:7b (Q4, ~4.7GB) fits fully in the
    # 10GB VRAM with room for context. See docs/local-llm-hosting.md.
    loadModels = [ "qwen2.5-coder:7b" ];

    environmentVariables = {
      # Serve a large context (model is 32K-native). Lower this if VRAM is tight
      # once the KV cache is added on top of the weights.
      OLLAMA_CONTEXT_LENGTH = "32768";
      # Shrinks the KV cache, buying back VRAM for context.
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };
}
