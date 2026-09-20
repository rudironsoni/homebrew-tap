cask "horca" do
  arch arm: "arm64", intel: "x64"

  version "1.4.205-horca.2"
  sha256 arm:   "d559a564358035c13d3694f224ddc6d9a4983bbd5342dcf894be5deb4d6410e0",
         intel: "0c306b020b44b5a41465cd8a610778de9cf6500742b98f92c5e58ef7eef5e1cd"

  url "https://github.com/rudironsoni/horca/releases/download/v#{version}/horca-macos-#{arch}.dmg"
  name "Horca"
  desc "Downstream Orca distribution with additional integrations"
  homepage "https://github.com/rudironsoni/horca"

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
