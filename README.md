# NixOS + Hyprland VM Test Setup

A modular, flake-based NixOS config for testing Hyprland in VirtualBox before going bare metal.

---

## Part 1 — Create the VirtualBox VM

In VirtualBox, **New → Expert Mode** (Expert lets you set everything in one screen):

| Setting | Value |
|---|---|
| Name | `nixtest` |
| Type | Linux |
| Version | Other Linux (64-bit) |
| Memory | 12288 MB |
| CPUs | 6 |
| Disk | 80 GB, VDI, dynamically allocated |

After it's created, **Settings → System → Motherboard**:
- ✅ **Enable EFI** (required for systemd-boot)
- Pointing device: USB Tablet (smoother mouse capture)

**Settings → System → Processor**:
- 6 CPUs, Enable PAE/NX

**Settings → Display → Screen**:
- Video Memory: **128 MB**
- Graphics Controller: **VMSVGA**
- ✅ **Enable 3D Acceleration** (Hyprland needs this; even with it on, you'll still use software rendering — that's expected.)
- Monitor count: 1 (more breaks resize)

**Settings → Storage**:
- Attach the NixOS ISO to the optical drive.

**Settings → Network**:
- NAT is fine for this test.

Boot the VM. You should land in the NixOS 25.11 graphical installer (GNOME live env).

---

## Part 2 — Install NixOS

Open **Install NixOS** from the live env (Calamares-style graphical installer):

1. **Welcome / Locale** — English, US.
2. **Region** — pick your timezone (America/New_York).
3. **Keyboard** — US.
4. **Partitions** — choose **Erase disk**. No swap (or with swap, your call — VM has 12 GB RAM). **Do not** check disk encryption.
5. **Users**:
    - Name: `Trey`
    - Login: `trey`
    - Hostname: `nixtest`
    - Set a password you'll remember (you'll type it a lot).
6. **Desktop / profile** — pick **GNOME** or **No desktop**. Doesn't matter much; we'll overwrite the config. If GNOME, you'll have a working desktop while we set up. Pick **No desktop** if you want to go straight to tty.
7. Confirm, install, reboot.
8. Remove the ISO from the optical drive when prompted (or via Devices menu).
9. Log in. If you picked GNOME, log in there. If no desktop, log in at the tty.

---

## Part 3 — Drop in this flake config

Once logged in, open a terminal:

```bash
# Enable flakes for this shell (the system doesn't have them yet)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Get the config files into ~/nixos-config — either:
#   a) git clone <your-repo-url> ~/nixos-config   (after you push this to your own remote)
#   b) copy from the host (VBox shared folder / scp / drag-and-drop after guest additions are running)
#   c) re-create from scratch using the files in this folder

# Replace the placeholder hardware-configuration.nix with the real one from your install
sudo cp /etc/nixos/hardware-configuration.nix \
        ~/nixos-config/hosts/nixtest/hardware-configuration.nix

# First rebuild — this enables flakes system-wide, installs Hyprland + everything
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixtest \
  --experimental-features 'nix-command flakes'
```

After it finishes (takes 5-30 min on first build), reboot:

```bash
sudo reboot
```

You'll come up at the **greetd / tuigreet** login screen. Pick `Hyprland`, log in.

---

## Part 4 — Once you're in Hyprland

Keybinds you'll want immediately (mod = Super = Windows key):

| Key | Action |
|---|---|
| `Super + Return` | Open kitty |
| `Super + Space` | hyprlauncher |
| `Super + B` | Firefox |
| `Super + E` | yazi file manager |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + L` | Lock (hyprlock) |
| `Super + Shift + Escape` | Logout menu (hyprshutdown) |
| `Super + I` | hyprsysteminfo |
| `Super + Shift + V` | Clipboard history picker |
| `Super + 1..9` | Switch workspace |
| `Super + Shift + 1..9` | Move window to workspace |
| `Super + h/j/k/l` | Focus left/down/up/right |
| `Print` | Region screenshot |
| `Shift + Print` | Window screenshot |
| `Ctrl + Print` | Full-output screenshot |

**Drop a wallpaper at** `~/.config/hypr/wallpaper.jpg` (or change the path in `home/hyprland.nix → services.hyprpaper`).

After any config edit:

```bash
cd ~/nixos-config
just rebuild      # or: sudo nixos-rebuild switch --flake .#nixtest
```

---

## Repo layout

```
nixos-config/
├── flake.nix                       # inputs (nixpkgs 25.11, home-manager) + outputs
├── justfile                        # `just rebuild`, `just update`, `just gc`
├── hosts/
│   └── nixtest/
│       ├── configuration.nix       # host-specific: bootloader, user, hostname
│       └── hardware-configuration.nix  # generated; replace placeholder after install
├── modules/
│   └── nixos/                      # system-level toggles
│       ├── default.nix             # imports everything below
│       ├── hyprland.nix            # programs.hyprland, greetd, PAM, portals, fonts
│       ├── audio.nix               # pipewire
│       └── vm.nix                  # VirtualBox guest additions (DELETE on bare metal)
└── home/                           # all home-manager (user-scope) config
    ├── default.nix                 # imports + user packages
    ├── colors.nix                  # Catppuccin Mocha palette (swap this file to retheme)
    ├── theme.nix                   # GTK, cursor, icons
    ├── hyprland.nix                # Hyprland + hyprpaper + hyprlock + hypridle
    ├── waybar.nix                  # status bar
    ├── kitty.nix                   # terminal
    ├── vscode.nix                  # editor
    ├── firefox.nix                 # browser
    └── mako.nix                    # notification daemon
```

### How it's plug-and-play

- **Add a new app**: drop a file in `home/`, add it to `home/default.nix` imports. One line.
- **Remove an app**: comment its line in `home/default.nix` imports. Rebuild.
- **Retheme everything**: replace `home/colors.nix` with another palette. Everything reads from it.
- **Try a different bar**: replace `home/waybar.nix` with `home/eww.nix` (or whatever) and update the import.
- **Move to bare metal**: delete `modules/nixos/vm.nix` import, remove the `WLR_*` env vars from `modules/nixos/hyprland.nix` and `home/hyprland.nix`, flip `animations.enabled = true` and `blur.enabled = true` in `home/hyprland.nix`. Run `just rebuild`.

---

## VirtualBox gotchas

- **Cursor disappears or freezes**: that's why `WLR_NO_HARDWARE_CURSORS=1` is set. If it still happens, log out + back in.
- **Hyprland exits to greeter immediately on first launch**: usually means `WLR_RENDERER_ALLOW_SOFTWARE=1` didn't take. Check `journalctl --user -u hyprland -b -e` (or just `Hyprland > /tmp/hl.log 2>&1` from tty3).
- **Slow / choppy animations even though they're off**: VirtualBox redraws the whole framebuffer for every change. Nothing to do about it; bare metal will be night-and-day.
- **Hyprlock won't unlock**: confirm `security.pam.services.hyprlock = {};` made it into the system config (it's in `modules/nixos/hyprland.nix`).
- **First `nixos-rebuild` is slow**: nixpkgs cache only goes so far; Hyprland's deps pull a lot. Subsequent builds are quick.

---

## Updating

```bash
cd ~/nixos-config
just update      # updates flake.lock (pulls newer nixpkgs / home-manager)
just rebuild     # apply
```

Roll back if something breaks: reboot, pick a previous generation at the systemd-boot menu.

```bash
just generations          # see what's available
sudo nixos-rebuild switch --flake .#nixtest --rollback   # last generation
```

---

## Notes on the things you specifically asked for

- **hyprlauncher**: installed as a user package, bound to `Super + Space`.
- **hyprpaper**: via `services.hyprpaper`. Drop wallpaper file at `~/.config/hypr/wallpaper.jpg`.
- **hyprlock**: via `programs.hyprlock`. Auto-locks at 5 min idle (via hypridle). Manual lock with `Super + L`. PAM enabled.
- **hyprcursor**: installed; the env vars (`HYPRCURSOR_SIZE`) are set. To actually see hyprcursor-rendered cursors you need a hyprcursor theme — Bibata XCursor is the current default and works in xwayland apps. Install a hyprcursor theme later if you want crisper Wayland cursors.
- **hyprshutdown**: bound to `Super + Shift + Escape`.
- **hyprsysteminfo**: bound to `Super + I`.
- **hypridle** (added): runs the lock + DPMS triggers. Without it, `programs.hyprlock` wouldn't auto-fire.
