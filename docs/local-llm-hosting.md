# Local LLM hosting — research & options

Research for the **"Local LLM provider"** TODO item, scoped to: a *dedicated
local-first coding agent* driving open-weight models that fit **fully in 10 GB
VRAM**, with the goal of letting the model edit this nixos-config.

## This machine

| Component | Spec | Relevance |
|-----------|------|-----------|
| GPU | **RTX 3080, 10 GB VRAM** (Ampere, compute 8.6) | The binding constraint. |
| CPU | Ryzen 9 5900X (12c/24t) | Strong; good for CPU offload if we ever relax the VRAM limit. |
| RAM | 32 GB, **no swap** | Fine for 7–14B; would matter for big CPU-offloaded models. |
| Disk | ~900 GB free | Non-issue; weights are a few GB each. |

> **Driver caveat:** the NVIDIA open kernel module (580.142) is loaded but there's
> a driver/library version mismatch right now, so `nvidia-smi` fails. A **reboot**
> is needed before GPU inference works. Worth doing before standing any of this up.

### The 10 GB budget — weights vs. context

VRAM holds *both* the model weights *and* the KV cache (context). On 10 GB:

- A **7B at Q4 (~4.7 GB)** leaves ~5 GB for KV cache → comfortably runs a large
  (~32K) context fully on GPU. **This is the sweet spot.**
- A **14B at Q4 (~9.0 GB)** fits the *weights* but leaves only ~1 GB → starves the
  context to a few K tokens before it spills to CPU. Marginal for agentic work,
  where context fills fast.
- Anything bigger (Qwen3-Coder 30B-A3B = 19 GB, gpt-oss-20b ~12 GB) does **not**
  fit fully and is out of scope under the "fully in VRAM" constraint (see
  *Stretch* below).

## Layer 1 — Serving the model

All three options below are already in your nixpkgs (26.05) with NixOS service
modules. Recommendation order for your use case:

### A. Ollama — **recommended**
- `ollama 0.30.5`, exposed as `services.ollama` (`acceleration = "cuda"`,
  `loadModels`, `host`, `port`).
- Wraps llama.cpp; pulls GGUF models by name (`ollama pull qwen2.5-coder:7b`),
  auto-manages load/unload, exposes an **OpenAI-compatible API** on `:11434`.
- Lowest-friction declarative path — a ~10-line `home/` or `modules/nixos/` module.
- This is the path nearly every local-agent guide assumes; OpenCode + Ollama is the
  canonical local setup.

### B. llama.cpp (`llama-server`) — for control
- `services.llama-cpp` (`model`, `host`, `port`, `extraFlags`).
- You point it at one GGUF file and tune flags (`--n-gpu-layers`, `--ctx-size`,
  flash-attention, KV-cache quant). Best raw control over the VRAM/context tradeoff,
  but you manage model files and only serve one model at a time.

### C. vLLM — **not recommended here**
- `vllm 0.16.0`, designed for high-throughput *concurrent* serving (PagedAttention).
- Overkill for a single-user workstation, and its memory model (pre-reserves VRAM,
  prefers unquantized/AWQ weights) fits 10 GB poorly. Skip unless you later want a
  multi-client server.

## Layer 2 — The model (fully-in-VRAM coders)

| Model | Size (Q4) | Notes |
|-------|-----------|-------|
| **Qwen2.5-Coder-7B-Instruct** | 4.7 GB | **Primary pick.** Best small dedicated coder; strong code gen, supports tool/function calling, leaves ample context headroom. |
| Qwen3-8B | ~5 GB | General model w/ hybrid "thinking"; solid tool use but not coder-specialised. Good for reasoning-heavier edits. |
| Qwen2.5-Coder-14B | 9.0 GB | Smarter, but context-starved on 10 GB (see budget note). Use Q4 only, expect small context. Borderline. |

Bump 7B to **Q5/Q6** (~5.4–6.2 GB) for a quality gain while still fitting context —
worth A/B testing once it's running.

**Honest limitation:** even the best 7B is meaningfully weaker than Claude at
*multi-step agentic file editing* — reliable tool calls, not getting lost across
many edits, recovering from mistakes. Expect it to handle focused single-file
nix edits and code-gen well, and to struggle with large multi-file refactors. The
"fully in VRAM" constraint caps the capability ceiling here; that's the real
tradeoff, not the serving tech.

## Layer 3 — The agent (dedicated, local-first)

Both are packaged in your nixpkgs; both just need to be pointed at the local
OpenAI-compatible endpoint from Layer 1 (`http://localhost:11434/v1/`).

### Crush — **primary harness**
- `crush 0.70.0` (Charmbracelet). Terminal coding agent with a polished Bubble Tea
  TUI; provider-agnostic via an `openai-compat` provider type that points straight
  at Ollama. Config lives in `~/.config/crush/crush.json` (or `.crush.json` per
  project) — declaratively writable from a `home/crush.nix` module, paralleling
  `claude-code.nix` and `pi.nix`. Directly advances the **"Pluggable coding
  agents"** TODO.

### OpenCode — **fallback**
- `opencode 1.15.10`. The other actively-developed open-source terminal agent;
  provider-agnostic, supports Ollama/local OpenAI-compatible backends. Keep it
  installed as a second harness to fall back to if Crush's agent loop misbehaves
  with a small local model — different harnesses stress tool-calling differently,
  so having both lets you pick whichever drives the 7B more reliably.

## Recommended starting setup

1. **Reboot** to clear the NVIDIA driver mismatch.
2. `modules/nixos/ollama.nix`: `services.ollama` with `acceleration = "cuda"` and
   `loadModels = [ "qwen2.5-coder:7b" ]`.
3. `home/crush.nix`: install `crush` and write `~/.config/crush/crush.json` with an
   `openai-compat` provider pointing at `http://localhost:11434/v1/` →
   `qwen2.5-coder:7b`. Keep `opencode` installed as the fallback harness.
4. `just build`, then iterate: try Q5/Q6 of the 7B, and test the 14B to feel the
   speed/quality/context tradeoff firsthand.

This keeps Claude Code as your primary harness and adds a fully-local,
zero-cost option for editing this config offline.

## Stretch (if you later relax "fully in VRAM")

The single biggest capability jump for *this* hardware is **Qwen3-Coder-30B-A3B**
(MoE, only ~3.3B params active per token). At Q4 (~19 GB) it won't fit 10 GB, but
because so few params are active, partial CPU offload stays usable on the 5900X —
far better tokens/sec than a dense 30B. If the 7B proves too weak for agentic
nixos-config edits, this is the next thing to benchmark.

---
*Sources: nixpkgs 26.05 (verified locally: ollama 0.30.5, llama-cpp, vllm 0.16.0,
opencode 1.15.10, aider-chat 0.86.1; services.ollama/llama-cpp/litellm modules).
Ollama model library (qwen2.5-coder, qwen3-coder sizes). Local-LLM/coding-agent
landscape surveys, mid-2026.*
