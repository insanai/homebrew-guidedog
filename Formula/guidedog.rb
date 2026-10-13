# Homebrew formula for the Guidedog release binaries, rendered by tools/release/formula.sh
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "0.6.2"
  license "AGPL-3.0-or-later"

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.2/guidedog-macos-arm64.tar.gz"
      sha256 "933e9067e755c13f91aab31e5b3da88066b3a6893d9d51abf6503b39ff322725"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.2/guidedog-macos-amd64.tar.gz"
      sha256 "9279e88bca42814cf8df050e023cc3e2c28a6812f8178c69b3b8a796d24ec2ea"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.2/guidedog-linux-arm64.tar.gz"
      sha256 "32d557d253d206a646005c5456fe25e4a1e517eadc17e3675f2ea212d4c81ea9"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.6.2/guidedog-linux-amd64.tar.gz"
      sha256 "1e8b9a16d9749d98efdd16d487f06e866542d5d51624f109ee9c9e527443b619"
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
