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
built from [rudironsoni/orca](https://github.com/rudironsoni/orca) and
released on [rudironsoni/orca-builds](https://github.com/rudironsoni/orca-builds).
Installs side by side with official Orca — distinct app (`Horca.app`),
bundle id (`com.rudironsoni.horca`), URL protocol (`horca:`), CLI
(`horca`), and state root (`~/.horca`).

```sh
brew install --cask rudironsoni/tap/horca
```

- Horca's in-app updater is intentionally disabled; `brew upgrade --cask horca`
  is the update path (the cask sets no `auto_updates`).
- The cask is bumped automatically by the `bump-horca-cask` workflow, which
  polls the latest orca-builds release and commits with this repository's own
  `GITHUB_TOKEN`. No cross-repository write credentials exist.
- `brew zap horca` removes only Horca-owned state; an installed official
  Orca (app, `~/.orca`, Application Support, Keychain, TCC grants) survives.
