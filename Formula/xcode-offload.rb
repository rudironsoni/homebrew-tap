class XcodeOffload < Formula
  desc "APFS-backed external storage for Xcode and CoreSimulator"
  homepage "https://github.com/rudironsoni/xcode-offload"
  url "https://github.com/rudironsoni/xcode-offload/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "6648eec86e78feebac81b436f46ad8f223e8af436ee550fe12afbd8cd1a631d1"
  license "MIT"

  depends_on xcode: ["16.3", :build]
  depends_on macos: :ventura

  def install
    ENV["XCODE_OFFLOAD_RELEASE_TAG"] = "v#{version}"
    system "make", "generate-version-source"
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "xcode-offload"
    bin.install ".build/release/xcode-offload"
  end

  test do
    assert_match "xcode-offload #{version}", shell_output("#{bin}/xcode-offload version")
  end
end
