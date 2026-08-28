# Rudironsoni Homebrew Tap

Homebrew formulae for Rudironsoni tools.

## Install

```sh
brew install rudironsoni/tap/macos-offload
```

Or tap first:

```sh
brew tap rudironsoni/tap
brew install macos-offload
```

## Upgrade

```sh
brew update
brew upgrade macos-offload
```

## Horca

Personal downstream distribution of [Orca](https://github.com/stablyai/orca),
built and released from [rudironsoni/orca](https://github.com/rudironsoni/orca).
Installs side by side with official Orca — distinct app (`Horca.app`),
bundle id (`com.rudironsoni.horca`), URL protocol (`horca:`), CLI
(`horca`), and state root (`~/.horca`).

```sh
brew install --cask rudironsoni/tap/horca
```

Install the newest beta:

```sh
brew install --cask rudironsoni/tap/horca@beta
```

- Horca's in-app updater is intentionally disabled; `brew upgrade --cask horca`
  is the update path (the cask sets no `auto_updates`).
- Stable updates follow each successful Horca `main` release. Beta updates
  follow releases created with the `Horca: Beta Release` workflow.
- The tap reacts to release dispatches and checks both channels every hour. It
  verifies release checksums and validates the cask before it updates `main`.
- `brew zap horca` removes only Horca-owned state; an installed official
  Orca (app, `~/.orca`, Application Support, Keychain, TCC grants) survives.
