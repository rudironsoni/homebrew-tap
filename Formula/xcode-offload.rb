class XcodeOffload < Formula
  desc "APFS-backed external storage for Xcode and CoreSimulator"
  homepage "https://github.com/rudironsoni/xcode-offload"
  url "https://github.com/rudironsoni/xcode-offload/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "9d9e5af55ee5ba6bb6ac8392b32e80fe35188abc51b18326efa752434c847b9f"
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
