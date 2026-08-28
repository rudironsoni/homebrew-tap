cask "horca@beta" do
  arch arm: "arm64", intel: "x64"

  version "1.4.178-horca-beta.3"
  sha256 arm:   "5e27aa629755801df3245727d34d6e35c4b2a9a3a0ade72986b678495f1df8c9",
         intel: "fbdb5ec5dbe66da2cc919b6c3fc1b1422a0312782dc307bdcf04791726baa1ea"

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
