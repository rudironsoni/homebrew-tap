cask "horca@beta" do
  arch arm: "arm64", intel: "x64"

  version "1.4.178-horca-beta.2"
  sha256 arm:   "0077a11827bc87fd5dea3896b297da1139bc7f38cbbf8f95f773fd69f0949e98",
         intel: "150e1e541ae18b0f6b4e7f9a600378cb608769abba85d30c3897168a2ca2d212"

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
