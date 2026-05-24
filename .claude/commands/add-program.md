Add a new program to this NixOS config. The program name is: $ARGUMENTS

Follow the modularity patterns established in this project exactly.

## Step 1: Determine install method

Check whether the program has a home-manager module (`programs.<name>`) or is available in nixpkgs. If neither, the user must provide a flake input — ask them for it.

Three patterns exist:

**A) Home-manager module (preferred when available)** — like `firefox.nix` or `ghostty.nix`:
```nix
{ pkgs, ... }:
{
  programs.<name> = {
    enable = true;
    # config goes here
  };
}
```

**B) Nixpkgs package (no home-manager module)** — just add to `home.packages` in `home/default.nix` inline. Only create a separate file if the program needs additional config files or settings beyond the package.

**C) External flake input (not in nixpkgs)** — like `zen.nix`:
```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```
This also requires adding the input to `flake.nix` and works because `extraSpecialArgs = { inherit inputs; }` is already configured.

## Step 2: Create `home/<name>.nix`

- Match the style of existing files (see `ghostty.nix`, `codium.nix`, `firefox.nix`, `zen.nix`).
- If the program needs theming, import colors: `let colors = import ./colors.nix; in` and use values as `"#${colors.base}"` or `"rgb(${colors.mauve})"`. Colors are hex without `#` — see `home/colors.nix`.
- Keep it minimal. Don't add config the user didn't ask for.

## Step 3: Wire it up

- Add `./name.nix` to the `imports` list in `home/default.nix`.
- If using pattern C, add the flake input to `flake.nix` under `inputs`.

## Step 4: Verify

- Run `just build` to confirm it evaluates without errors.

## Reminders

- Do NOT add packages to `home/default.nix`'s `home.packages` list if you created a dedicated .nix file — put them in the new file.
- One file per program in `home/`. The file IS the module boundary.
- `home/default.nix` is the entry point — it imports everything and declares shared packages.
