cask "horca" do
  arch arm: "arm64", intel: "x64"

  version "1.4.196-horca.1"
  sha256 arm:   "7e670c1ecae5b6796abb3f86e5a6e69a33e8c15d45b374b6754c836265e59c24",
         intel: "e3b321627c0d3e6fbae0291b25ae94fb0271d9eb13e53e8b476931a099d9e95c"

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
