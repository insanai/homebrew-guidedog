# Homebrew formula for the Guidedog release binaries, rendered by cargo xtask release formula
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "1.0.0-beta.1"
  license "LGPL-3.0-or-later"

  # Graphviz is linked statically into the programs, so there are no dependencies.

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.1/guidedog-macos-arm64.tar.gz"
      sha256 "1669c6a56ce368da6a1e275414a9620a7fc0a870eed4478b2628af617447e1a2"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.1/guidedog-macos-amd64.tar.gz"
      sha256 "bca0e11382e85aea5af59ce029e2ecfe8648402ffe03d9dca0bc5c3fab53d5f9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.1/guidedog-linux-arm64.tar.gz"
      sha256 "5082f1df3fdd9aa852daa2559b5b7d0e609961fdfe4afe53c4e1cf0172748731"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.1/guidedog-linux-amd64.tar.gz"
      sha256 "3dfbebc3c8189cbeff05a8ade620dee72a1400ed12c583b3f4df2d5679c8a9a8"
    end
  end

  def install
    # Publishing, discussions and Graphviz rendering are built into Guidedog.
    bin.install "guidedog"
    doc.install "NOTICE", "CHANGELOG.md", "SOURCE.txt", "guidedog.build.json"
  end

  test do
    assert_match "guidedog #{version}", shell_output("#{bin}/guidedog --version")
    system bin/"guidedog", "quickstart", "docs", "-q", "-p", "Demo", "-a", "Homebrew"
    (testpath/"docs/index.rst").open("a") do |file|
      file.write "\n.. digraph:: smoke\n\n   source -> html\n"
    end
    system bin/"guidedog", "build", "html", "docs", "-W"
    assert_path_exists testpath/"docs/_build/html/index.html"
    system bin/"guidedog", "build", "pdf", "docs", "-W"
    assert_path_exists testpath/"docs/_build/pdf/demo-en.pdf"
    system bin/"guidedog", "dsc", "init", "eds", "--prefix=eds", "--author=Homebrew"
    cd "eds" do
      system bin/"guidedog", "dsc", "new", "Cache policy", "--labels=architecture"
      system bin/"guidedog", "dsc", "build", "--target=html"
      assert_path_exists testpath/"eds/_build/html/index.html"
    end
    system bin/"guidedog", "pages", "init", "--repository=octo/manual", "--project=docs"
    assert_path_exists testpath/"pages.toml"
  end
end
