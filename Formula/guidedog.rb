# Homebrew formula for the Guidedog release binaries, rendered by tools/release/formula.sh
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "0.6.1"
  license "AGPL-3.0-or-later"

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.1/guidedog-macos-arm64.tar.gz"
      sha256 "4244a200030afb18648ac0dc99bd945c7e36422fb7d48aac5189ba92223fb958"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.1/guidedog-macos-amd64.tar.gz"
      sha256 "9ce0bdd512e93d58b80448248bb1cf94c3c6ac92d2d027c75da75ed175808677"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.1/guidedog-linux-arm64.tar.gz"
      sha256 "4d1cdde9eee45256143f844258dbac1dd4fa1593223a6ba557ea2782a15c0be1"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.1/guidedog-linux-amd64.tar.gz"
      sha256 "9d5d0325d8e8e9b9eeab119b4b962d23f12f7e24f1b7fb993d1f7ab75fa27853"
    end
  end

  def install
    # dsc keeps discussion catalogs, and guidedog-pages publishes to GitHub Pages; both build
    # with this guidedog.
    bin.install "guidedog", "dsc", "guidedog-pages"
    doc.install "NOTICE", "CHANGELOG.md", "SOURCE.txt", "guidedog.build.json"
  end

  test do
    assert_match "guidedog #{version}", shell_output("#{bin}/guidedog --version")
    system bin/"guidedog", "quickstart", "docs", "-q", "-p", "Demo", "-a", "Homebrew"
    system bin/"guidedog", "build", "html", "docs", "-W"
    assert_path_exists testpath/"docs/_build/html/index.html"
    system bin/"guidedog", "build", "pdf", "docs", "-W"
    assert_path_exists testpath/"docs/_build/pdf/demo-en.pdf"
    assert_match "dsc #{version}", shell_output("#{bin}/dsc --version")
    system bin/"dsc", "init", "eds", "--prefix=eds", "--author=Homebrew"
    cd "eds" do
      system bin/"dsc", "new", "Cache policy", "--labels=architecture"
      system bin/"dsc", "build", "--target=html", "--guidedog=#{bin}/guidedog"
      assert_path_exists testpath/"eds/_build/html/index.html"
    end
    assert_match "guidedog-pages #{version}", shell_output("#{bin}/guidedog-pages --version")
    system bin/"guidedog-pages", "init", "--repository=octo/manual", "--project=docs"
    assert_path_exists testpath/"pages.toml"
  end
end
