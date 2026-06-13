# TODO

Running list of known gaps and planned work for this config. Newest ideas at the
bottom of each section.

## Known gaps (current rough edges)

- [ ] **`nixtest` is not buildable.** It has `configuration.nix` +
  `hardware-configuration.nix` but no `nixosConfigurations.nixtest` output in
  `flake.nix`. The home-manager user is hardcoded to `kida` (in both `flake.nix`
  and `home/default.nix`), while `hosts/nixtest/configuration.nix` declares user
  `trey`. Needs a `flake.nix` refactor to generate hosts generically and
  parameterize the user before a real second host works.
- [ ] **`just fmt` errors.** It runs `nix fmt`, but `flake.nix` defines no
  `formatter` output. Add `formatter.<system>` (e.g. `nixpkgs-fmt` or `nixfmt`).
- [ ] **`just` recipes hardcode `.#atlantis`.** Building another host requires a
  manual `nixos-rebuild` invocation. Parameterize the recipes once multi-host is
  wired.
- [ ] **`dbus-broker` reload times out on every rebuild.** `nixos-rebuild switch`
  exits non-zero (code 4) because the user-unit `dbus-broker.service` reload hangs
  for 90s then gets killed (`Reload operation timed out`). The broker keeps running
  and the switch otherwise succeeds — it's cosmetic but makes `just rebuild` always
  look failed. Known NixOS quirk (dbus-broker's `ExecReload`); investigate a fix.
- [ ] **`result` symlink is committed; no `.gitignore`.** The `nixos-rebuild build`
  artifact `result` is tracked in git and there's no `.gitignore`, so it churns on
  every build. Add a `.gitignore` (at least `result`) and `git rm --cached result`.

## Planned work

- [ ] **Customize the lock screen.** Research hyprlock options and theme/customize
  the lock screen.
- [ ] **Pluggable coding agents.** Set up `coding-agents.nix` (or similar) to allow
  harnesses and LLM models beyond claude-code / Anthropic. (We already pull `pi`
  from the `llm-agents.nix` input — build on that.)
- [x] **Local LLM provider.** Ollama (`modules/nixos/ollama.nix`, `ollama-cuda`)
  serving `qwen2.5-coder:7b`, driven by the Crush harness (`home/crush.nix`) with
  OpenCode as fallback. Research and options in
  [`docs/local-llm-hosting.md`](docs/local-llm-hosting.md).
- [ ] **Migrate Hyprland to Lua config (`configType = "lua"`).** We pin
  `configType = "hyprlang"` in `home/hyprland.nix` to keep the home-manager
  `settings = { ... }` attrset form, but Hyprland is winding down hyprlang: as of
  0.55 the parser lives under `src/config/legacy/`, and the wiki + shipped example
  config (`example/hyprland.lua`) are Lua-only. Hyprlang still works but lags on new
  syntax (the 0.55 upgrade already broke `togglesplit`, `dwindle:pseudotile`, and the
  whole windowrule grammar). Evaluate moving to Lua config to stay on the supported
  path.
- [ ] **Customize the login screen.** Research and customize the greeter (currently
  greetd + tuigreet in `modules/nixos/hyprland.nix`).
- [ ] **Bluetooth headset/mic issues.** Investigate Bluetooth headset/microphone
  problems (relevant: `modules/nixos/bluetooth.nix`, and the wireplumber
  bluetooth-policy tweak in `modules/nixos/audio.nix`).
- [ ] **Work-laptop integration.** Make the setup modular enough to integrate into
  a work laptop (ties into the multi-host refactor above).
