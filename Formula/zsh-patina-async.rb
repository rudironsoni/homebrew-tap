class ZshPatinaAsync < Formula
  desc "Blazingly fast Zsh syntax highlighter (fork with async line-pre-redraw)"
  homepage "https://github.com/rudironsoni/zsh-patina"
  head "https://github.com/rudironsoni/zsh-patina.git", branch: "feat/async-line-pre-redraw"
  license "MIT"
  depends_on "rust" => :build
  uses_from_macos "zsh" => :test

  def install
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "fat"
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"zsh-patina", "completion",
      shell_parameter_format: :none, shells: [:zsh])
  end

  def caveats
    <<~EOS
      Initialize zsh-patina at the end of your `.zshrc` file by executing:
        echo 'eval "$(#{opt_bin}/zsh-patina activate)"' >> ~/.zshrc
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zsh-patina --version")
    output = shell_output("zsh -c 'eval \"$(#{bin}/zsh-patina activate)\" && type -w zsh-patina'")
    assert_match "zsh-patina: function", output
  end
end