class MacosOffload < Formula
  desc "APFS-backed external storage for Xcode and CoreSimulator"
  homepage "https://github.com/rudironsoni/macos-offload"
  url "https://github.com/rudironsoni/macos-offload/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "699cd4540ab707f96c882976deeade8fa02797068cdf480258dd7ad1ed7db0e4"
  license "MIT"

  depends_on xcode: ["16.3", :build]
  depends_on macos: :ventura

  def install
    ENV["MACOS_OFFLOAD_RELEASE_TAG"] = "v#{version}"
    system "make", "generate-version-source"
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "macos-offload"
    bin.install ".build/release/macos-offload"
  end

  test do
    assert_match "macos-offload #{version}", shell_output("#{bin}/macos-offload version")
  end
end
