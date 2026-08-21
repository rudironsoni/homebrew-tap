# Humpback — personal downstream distribution of Orca, installable side by
# side with the official Orca app (distinct app name, bundle id, protocol,
# CLI, and state root; see rudironsoni/orca docs/reference/humpback-distribution.md).
#
# BOOTSTRAP: version and sha256 below are placeholders until the first
# Humpback release exists on rudironsoni/orca-builds. Fill them manually once
# (shasum -a 256 <dmg>), or run the bump-humpback-cask workflow; afterwards
# the scheduled bump workflow keeps them current.
cask "humpback" do
  arch arm: "arm64", intel: "x64"

  version "0.0.0-humpback.0" # REPLACE_WITH_FIRST_RELEASE
  sha256 arm:   "REPLACE_WITH_ARM64_SHA256",
         intel: "REPLACE_WITH_X64_SHA256"

  url "https://github.com/rudironsoni/orca-builds/releases/download/v#{version}/humpback-macos-#{arch}.dmg"
  name "Humpback"
  desc "Personal downstream distribution of the Orca agent workbench"
  homepage "https://github.com/rudironsoni/orca-builds"

  livecheck do
    url :url
    regex(/^v(\d+(?:\.\d+)+-humpback\.\d+)$/i)
    strategy :github_latest
  end

  # No auto_updates: Humpback's in-app updater is intentionally disabled; this
  # cask (or a GitHub Releases download) is the only update path.

  depends_on macos: ">= :big_sur"

  app "Humpback.app"
  binary "#{appdir}/Humpback.app/Contents/Resources/bin/humpback"

  # Zap removes ONLY Humpback-owned state, keyed on the Humpback bundle id and
  # product name. Official Orca's app, ~/.orca, Application Support/Orca,
  # Keychain items, caches, preferences, and TCC grants must survive a zap.
  # Paths must be re-verified against a real install before first publication
  # (Phase 2 human acceptance) — never copy Orca's zap stanza.
  zap trash: [
    "~/.humpback",
    "~/Library/Application Support/Humpback",
    "~/Library/Caches/com.rudironsoni.humpback",
    "~/Library/Caches/com.rudironsoni.humpback.ShipIt",
    "~/Library/HTTPStorages/com.rudironsoni.humpback",
    "~/Library/Preferences/com.rudironsoni.humpback.plist",
    "~/Library/Saved Application State/com.rudironsoni.humpback.savedState",
  ]
end
