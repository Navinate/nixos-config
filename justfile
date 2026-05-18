# Run `just` with no args to see available recipes.

default:
    @just --list

# Rebuild & switch the system
rebuild:
    sudo nixos-rebuild switch --flake .#nixtest

# Build & test without making it the default boot entry
test:
    sudo nixos-rebuild test --flake .#nixtest

# Build only, don't activate
build:
    nixos-rebuild build --flake .#nixtest

# Update flake inputs
update:
    nix flake update

# Garbage-collect old generations (system + user)
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Format all .nix files in the repo
fmt:
    nix fmt

# Drop into a repl with the flake loaded
repl:
    nix repl -f flake:.

# List system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
