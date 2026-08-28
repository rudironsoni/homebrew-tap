cask "horca@beta" do
  arch arm: "arm64", intel: "x64"

  version "1.4.178-horca-beta.1"
  sha256 arm:   "f8552f060b725ffc312bc5ff53c9338a7a270671901971a41846738048d53916",
         intel: "f8ac441b4b307fecb2ec39f30e764d407eb52d64ff747b56845e7deabfcb526a"

  url "https://github.com/rudironsoni/orca/releases/download/v#{version}/horca-macos-#{arch}.dmg"
  name "Horca"
  desc "Downstream Orca distribution with additional integrations"
  homepage "https://github.com/rudironsoni/orca"

  livecheck do
    url :url
    regex(/^v(\d+(?:\.\d+)+-horca-beta\.\d+)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"] || !release["prerelease"]

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  conflicts_with cask: "horca"
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
