{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
  ];
  home.file.".claude/settings.json".text = builtins.toJSON {
    model = "opus";
    effort = "high";
  };

  home.file.".claude/CLAUDE.md".text = ''
    # Claude Code Rules

    ## Settings Management

    Claude Code settings are managed declaratively via Nix in `~/nixos-config/home/claude-code.nix`.
    Do NOT edit `~/.claude/settings.json` directly — changes will be overwritten on rebuild.
    To update settings, modify the Nix file and run `just rebuild`.

    ## 1. Think Before Coding

    **Don't assume. Don't hide confusion. Surface tradeoffs.**

    Before implementing:
    - State your assumptions explicitly. If uncertain, ask.
    - If multiple interpretations exist, present them - don't pick silently.
    - If a simpler approach exists, say so. Push back when warranted.
    - If something is unclear, stop. Name what's confusing. Ask.

    ## 2. Simplicity First

    **Minimum code that solves the problem. Nothing speculative.**

    - No features beyond what was asked.
    - No abstractions for single-use code.
    - No "flexibility" or "configurability" that wasn't requested.
    - No error handling for impossible scenarios.
    - If you write 200 lines and it could be 50, rewrite it.

    Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

    ## 3. Surgical Changes

    **Touch only what you must. Clean up only your own mess.**

    When editing existing code:
    - Don't "improve" adjacent code, comments, or formatting.
    - Don't refactor things that aren't broken.
    - Match existing style, even if you'd do it differently.
    - If you notice unrelated dead code, mention it - don't delete it.

    When your changes create orphans:
    - Remove imports/variables/functions that YOUR changes made unused.
    - Don't remove pre-existing dead code unless asked.

    The test: Every changed line should trace directly to the user's request.

    ## 4. Goal-Driven Execution

    **Define success criteria. Loop until verified.**

    Transform tasks into verifiable goals:
    - "Add validation" -> "Write tests for invalid inputs, then make them pass"
    - "Fix the bug" -> "Write a test that reproduces it, then make it pass"
    - "Refactor X" -> "Ensure tests pass before and after"

    For multi-step tasks, state a brief plan:
    1. [Step] -> verify: [check]
    2. [Step] -> verify: [check]
    3. [Step] -> verify: [check]

    Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.



    ## 5. Godot guidelines

    - don't guess about godot features, functions, or interfaces.  always ground yourself in the truth via the documentation.  The documentation's git repo is ~/games/godot-docs/.
    - write extremely minimal comments in gdscript files,  do not write any comments anywhere else.
    - prefer gdscript over other languages, always statically typed.
    - do not over complicate things, keep features simple and easy to modify.
    - DO NOT CREATE ASSETS (models, images, sounds, etc) without EXPLICIT instructions to do so
        * even then, make intenionally placeholder assets with not artistic goal, pure programmer art
  '';
}
