cask "horca" do
  arch arm: "arm64", intel: "x64"

  version "1.4.202-horca.4"
  sha256 arm:   "25ee2b56259454f5618d6e8f7510625e578e8539010ff5381a6c3ce94726f782",
         intel: "680bf43cda7c8ea854a78a27c091ad5ff7519bd7a542a7e080d77ec504e2739b"

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
