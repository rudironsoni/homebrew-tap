cask "horca" do
  arch arm: "arm64", intel: "x64"

  version "1.4.197-horca.4"
  sha256 arm:   "7be2cf32f4137f886f66e2c8d565fa0f8d8d1b21f1dd3f3ab8510d2cd4868f4d",
         intel: "1c6711cd920a338f7e233cdf7d8d277b2b0e47efa400fc4f90c32cb42d0c2b5a"

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
