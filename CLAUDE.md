# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
just rebuild      # sudo nixos-rebuild switch --flake .#atlantis  (build + activate)
just test         # build + activate without setting as default boot entry
just build        # build only, don't activate
just update       # nix flake update (updates flake.lock)
just gc           # garbage-collect old generations (system + user)
just fmt          # nix fmt (format all .nix files)
just repl         # nix repl with flake loaded
just generations  # list system generations
```

Roll back: reboot and select a previous generation at the systemd-boot menu, or:

```bash
sudo nixos-rebuild switch --flake .#atlantis --rollback
```

## Architecture

This is a flake-based NixOS + Hyprland config targeting a single host (`atlantis`), currently running inside VirtualBox for testing before bare-metal deployment. Inputs are pinned to `nixpkgs 25.11` and `home-manager release-25.11`.

**Two configuration layers:**

- `modules/nixos/` — system-level (runs as root). Imported by `hosts/atlantis/configuration.nix`. Contains: `hyprland.nix` (greetd/tuigreet, PAM, portals, fonts), `audio.nix` (pipewire), `vm.nix` (VirtualBox guest additions — delete this on bare metal).
- `home/` — user-level via home-manager. Imported as `users.trey` in `flake.nix`. Contains per-app config files; `default.nix` is the entry point that imports them all and declares user packages.

**Theming:** `home/colors.nix` is the single source of truth — a Catppuccin Mocha palette (hex values without `#`). All other home modules import it. To retheme everything, replace this one file.

**Adding/removing apps:** Drop a file in `home/`, add/remove its import in `home/default.nix`. No other changes needed.

**Bare-metal migration checklist:**

- Remove `./vm.nix` from `modules/nixos/default.nix`
- Remove `WLR_*` env vars from `modules/nixos/hyprland.nix` and `home/hyprland.nix`
- Enable animations and blur in `home/hyprland.nix`

## Notes

- `hardware-configuration.nix` is machine-generated and gitignored-in-spirit — replace it after a fresh install with `sudo cp /etc/nixos/hardware-configuration.nix hosts/atlantis/`.
- `hyprshutdown` is commented out in `home/default.nix` — not yet in nixpkgs 25.11; uncomment after 26.05 or add an overlay.
- Colors in `.nix` files are used as `"#${colors.base}"` or `"rgb(${colors.mauve})"` — no leading `#` in `colors.nix`.
