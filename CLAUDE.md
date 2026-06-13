# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A flake-based, declarative configuration for the whole machine — both the OS
(NixOS) and the user's applications (home-manager) — targeting Hyprland on
Wayland. Design goals, in priority order:

1. **Modular.** Every program the user touches often, or that carries non-trivial
   config, gets its own file. Anything tied to specific hardware also gets its own
   file (e.g. `modules/nixos/nvidia.nix`). The file *is* the module boundary.
2. **Multi-host.** One repo should configure several machines, selected by which
   host you build. Two host directories exist today: `atlantis` (the personal
   desktop, bare metal) and `nixtest` (originally a VirtualBox VM used to bootstrap
   this config). See [Multi-host](#multi-host) for the current state and its gaps.
3. **LLM-agent editable & testable.** The layout is intentionally regular so a
   coding agent can add/upgrade/modify the OS and verify with `just build`. Keep it
   that way: predictable file names, one concern per file, minimal cleverness.

## Commands

All `just` recipes currently hardcode the `atlantis` host (see [Known gaps](#known-gaps)).

```bash
just rebuild      # sudo nixos-rebuild switch --flake .#atlantis   (build + activate, set as boot default)
just test         # sudo nixos-rebuild test  --flake .#atlantis    (build + activate, NOT a boot entry)
just build        # nixos-rebuild build      --flake .#atlantis    (build only, no activate, no sudo)
just update       # nix flake update         (updates flake.lock)
just gc           # garbage-collect old generations (system + user)
just fmt          # nix fmt                  (see Known gaps — no formatter output defined yet)
just repl         # nix repl -f flake:.      (repl with the flake loaded)
just generations  # list system generations
```

The safest verification loop for an agent is `just build` (no privileges, no
activation). Use `just test` to activate without touching the boot default;
`just rebuild` makes it the default boot entry.

Roll back: reboot and pick a previous generation at the systemd-boot menu, or:

```bash
sudo nixos-rebuild switch --flake .#atlantis --rollback
```

## Repository layout

```
flake.nix                 # inputs + nixosConfigurations; wires home-manager and the catppuccin module filter
justfile                  # build/activate/maintenance recipes (hardcoded to .#atlantis)

hosts/<host>/
  configuration.nix       # per-host system config: hostname, user, bootloader, locale, imports modules/nixos
  hardware-configuration.nix  # machine-generated; replace per machine after install

modules/nixos/            # system-level (root). Aggregated by modules/nixos/default.nix
  default.nix             # imports every system module below
  hyprland.nix            # Hyprland session, greetd/tuigreet, PAM for hyprlock, xdg portals, fonts, dconf
  audio.nix               # pipewire (alsa/pulse) + wireplumber bluetooth policy
  bluetooth.nix           # bluez + blueman + xpadneo (Xbox controller)
  nvidia.nix              # NVIDIA proprietary/open driver (hardware-specific)
  steam.nix               # Steam + steam-hardware
  obs.nix                 # OBS Studio + v4l2loopback virtual camera
  zen.nix                 # system-wide Zen browser extension policies (/etc/zen/policies)

home/                     # user-level via home-manager. Aggregated by home/default.nix
  default.nix             # entry point: imports all home modules, catppuccin globals, shared home.packages, bash/git
  theme.nix               # cursor + GTK theme (Adwaita-dark) + prefer-dark
  darkman.nix             # darkman service + light/dark transition scripts (waybar/mako/hyprland/gtk)
  hyprland.nix            # Hyprland user config (keybinds, rules, colors from catppuccin palette)
  wayle.nix               # wayle status bar (built-in catppuccin-mocha palette)
  rofi.nix                # rofi launcher
  ghostty.nix             # ghostty terminal
  codium.nix  zed.nix     # editors
  firefox.nix  zen.nix    # browsers (zen.nix pulls the zen-browser flake input)
  spotify.nix             # spicetify-nix module (catppuccin mocha theme + extensions)
  obsidian.nix            # Obsidian
  claude-code.nix         # Claude Code settings (managed here, NOT ~/.claude/settings.json)
  pi.nix                  # `pi` coding agent from the llm-agents.nix flake input

.claude/commands/add-program.md   # project slash-command describing the add-a-program workflow
```

## Architecture

Inputs are pinned to `nixpkgs nixos-26.05` and `home-manager release-26.05`.
Other flake inputs: `zen-browser`, `spicetify-nix`, `catppuccin`, `llm-agents`
(all follow the same nixpkgs). `system.stateVersion` is `25.11` — do not bump
casually.

**Two configuration layers:**

- `modules/nixos/` — system-level, runs as root. `modules/nixos/default.nix`
  imports every module in the directory; a host pulls them all in via
  `imports = [ ../../modules/nixos ]`. To add/remove a system module, edit
  `default.nix`.
- `home/` — user-level via home-manager. `home/default.nix` is the entry point:
  it imports each per-app module, sets the catppuccin globals, declares shared
  `home.packages`, and configures bash/git. To add/remove a user app, edit its
  import in `home/default.nix`.

`inputs` is threaded into both layers (`specialArgs` / `extraSpecialArgs`), so any
module can take `{ inputs, ... }` and reference a flake input directly (see
`home/zen.nix`, `home/spotify.nix`, `home/pi.nix`).

**Theming** uses the [catppuccin/nix](https://github.com/catppuccin/nix) flake,
flavor `mocha`, accent `mauve` (set in `home/default.nix` under `catppuccin`).
Rather than importing the full catppuccin home-manager module (which would
auto-theme apps whose configs we own and cause clashes), `flake.nix` uses
`importApply` with an explicit **filter list** — only `ghostty, mako, waybar, bat,
fzf, eza, gtk` modules are even loaded. With `autoEnable = true`, those apps theme
themselves; per-app `.enable` is not needed. To add catppuccin theming for a new
app, add its module name to that filter list in `flake.nix`.

Some apps are themed outside that mechanism on purpose:
- `home/theme.nix` — GTK uses `Adwaita-dark` (catppuccin's GTK theme was archived
  upstream); icons still come from catppuccin.
- `home/wayle.nix` — uses wayle's own built-in catppuccin-mocha palette verbatim.
- `home/spotify.nix` — uses spicetify's catppuccin theme.
- `home/darkman.nix` — light/dark switching reads the palette JSON via
  `config.catppuccin.sources.palette` and restarts waybar/mako and re-colors
  Hyprland borders.

## Multi-host

The intended model: each machine is a directory under `hosts/`, listed as a
`nixosConfigurations.<host>` output in `flake.nix`, and you select it at build time
(`nixos-rebuild ... --flake .#<host>`). System modules and the `home/` tree are
shared; only `hosts/<host>/configuration.nix` and `hardware-configuration.nix`
differ.

**Current state — this is only partly wired up:**

- `flake.nix` defines **only** `nixosConfigurations.atlantis`. `hosts/nixtest/`
  has both config files but is **not** a flake output, so `nixtest` cannot be
  built as-is.
- The home-manager user is **hardcoded as `kida`** inside the atlantis module
  block in `flake.nix` (`users.kida = { imports = [ ./home ... ]; }`), and
  `home/default.nix` hardcodes `home.username = "kida"`. Meanwhile
  `hosts/nixtest/configuration.nix` still declares the system user as `trey`.
- Every `just` recipe hardcodes `.#atlantis`.

So adding a real second host today requires refactoring `flake.nix` to generate
per-host configurations (and parameterizing the home-manager user) — it is not yet
just "drop in a host dir." Treat `nixtest` as a stale template until that refactor
happens.

## Adding a program

Prefer the project slash-command **`/add-program <name>`** (`.claude/commands/add-program.md`),
which encodes the conventions. In short:

1. Pick the install method: a home-manager module (`programs.<name>`, preferred), a
   plain nixpkgs package, or an external flake input.
2. For anything with real config, create `home/<name>.nix` (one file per program).
   A bare package with no extra config can just go in the `home.packages` list in
   `home/default.nix`.
3. Wire it: add `./<name>.nix` to `imports` in `home/default.nix` (and add the
   flake input to `flake.nix` if it's an external flake).
4. Verify with `just build`.

System-level or hardware-specific concerns go in `modules/nixos/` instead, added to
`modules/nixos/default.nix`.

## Claude Code settings

Claude Code's own settings are managed declaratively in `home/claude-code.nix` and
applied on rebuild. Do **not** edit `~/.claude/settings.json` by hand — it is
overwritten. Change the Nix file and run `just rebuild`.

## Known gaps & planned work

Real rough edges an agent will hit (non-buildable `nixtest`, `just fmt` errors,
hardcoded `.#atlantis`) and the roadmap live in [`TODO.md`](TODO.md). Check it
before assuming something is broken by your changes.

## Per-machine setup note

`hardware-configuration.nix` is machine-generated. After a fresh install on a host,
replace it with:

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/<host>/
```
