# Homebrew formula for the Guidedog release binaries, rendered by tools/release/formula.sh
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "0.2.3"
  license "AGPL-3.0-or-later"

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.3/guidedog-macos-arm64.tar.gz"
      sha256 "02139f5ed86f36cd06e30062f54c27774e6b08ed98590229008fc95ad180cdee"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.3/guidedog-macos-amd64.tar.gz"
      sha256 "39032ed4a67cdaceda565ee1c938776fabfdac9af89fa8569106115c33c794e6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.3/guidedog-linux-arm64.tar.gz"
      sha256 "38d95f846a5ea217936f839a7b2bbe0214a6836bbdae82480a71cc88dbac78e5"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.3/guidedog-linux-amd64.tar.gz"
      sha256 "1f04c9d7592419c2699b07e6c615ebd721fe496f826e958cd1ffa777664df348"
    end
  end

  def install
    bin.install "guidedog", "dsc" # dsc keeps discussion catalogs and builds with guidedog
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
  end
end
