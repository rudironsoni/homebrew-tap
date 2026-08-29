cask "horca" do
  arch arm: "arm64", intel: "x64"

  version "1.4.178-horca.17"
  sha256 arm:   "1f1095217a80262e4da842710ba591e5e590ac4ec244852895a990906659a1e4",
         intel: "837dfe9a1118001c79776b250bf2421e0d281ad8901630c728703e4976a7d40f"

  url "https://github.com/rudironsoni/orca/releases/download/v#{version}/horca-macos-#{arch}.dmg"
  name "Horca"
  desc "Downstream Orca distribution with additional integrations"
  homepage "https://github.com/rudironsoni/orca"

  livecheck do
    url :url
    regex(/^v(\d+(?:\.\d+)+-horca\.\d+)$/i)
    strategy :github_latest
  end

  conflicts_with cask: "horca@beta"
  depends_on macos: :monterey

  app "Horca.app"
  binary "#{appdir}/Horca.app/Contents/Resources/bin/horca"

  zap trash: [
    "~/.horca",
    "~/Library/Application Support/Horca",
    "~/Library/Caches/com.rudironsoni.horca",
    "~/Library/Caches/com.rudironsoni.horca.ShipIt",
    "~/Library/HTTPStorages/com.rudironsoni.horca",
    "~/Library/Preferences/com.rudironsoni.horca.plist",
    "~/Library/Saved Application State/com.rudironsoni.horca.savedState",
  ]
end
