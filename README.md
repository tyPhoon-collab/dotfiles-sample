# dotfiles-sample

Sample consumer repo for `core`.

This repo owns the flake and `flake.lock`. `core` is consumed as a non-flake input and provides reusable Home Manager / nix-darwin modules.

## Use

Fork this repo, then edit:

- `flake.nix`: inputs, usernames, host names, `coreConfig`
- `home.nix`: user-level modules imported with core
- `darwin.nix`: macOS system modules imported with core

## Minimum edits

Most first-run values are near the top of `flake.nix`.

- `inputs.core.url`: your `core` repo, if you maintain a fork
- `baseCoreConfig.identity`: your Git/Jujutsu name and email
- `profiles.linux.name`: Home Manager output name
- `profiles.linux.system`: usually `x86_64-linux`
- `profiles.linux.username`
- `profiles.linux.homeDirectory`
- `profiles.darwin.name`: nix-darwin output name
- `profiles.darwin.system`: `aarch64-darwin` for Apple Silicon, `x86_64-darwin` for Intel Mac
- `profiles.darwin.username`
- `profiles.darwin.homeDirectory`

Then run commands with your renamed output:

```sh
home-manager switch --flake .#<linux-profile-name>
darwin-rebuild switch --flake .#<darwin-profile-name>
```

By default, `inputs.core.url` points to the upstream `core` repository. For a fork, replace it with your own URL:

```nix
core = {
  url = "github:your-org/core";
  flake = false;
};
```

## Commands

Inspect outputs:

```sh
nix flake show
```

Build the standalone Home Manager activation package:

```sh
nix build .#homeConfigurations.sample-linux.activationPackage
```

Apply the standalone Home Manager profile:

```sh
home-manager switch --flake .#sample-linux
```

Build the macOS system configuration:

```sh
darwin-rebuild build --flake .#sample-darwin
```

## Notes

- Keep host-specific and private values in this consumer repo.
- Keep reusable defaults and public `core.*` options in `core`.
- Keep `flake.lock` here, not in `core`.
