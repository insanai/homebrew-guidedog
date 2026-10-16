# Homebrew formula for the Guidedog release binaries, rendered by cargo xtask release formula
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "1.0.0-beta.2"
  license "LGPL-3.0-or-later"

  # Graphviz is linked statically into the programs, so there are no dependencies.

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.2/guidedog-macos-arm64.tar.gz"
      sha256 "e1e648aad665f4ab6923ab743fd9b780411624fe0715f1af11cb51f80b4112ff"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.2/guidedog-macos-amd64.tar.gz"
      sha256 "c7e71112bc097ccc6973aee186c6f1ff24accf7181409d78bb896c946459d5f7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.2/guidedog-linux-arm64.tar.gz"
      sha256 "e04e5d55ea9f5eb782f083be120667c6b8a6fa6db3a7f59fa072df989982a471"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.2/guidedog-linux-amd64.tar.gz"
      sha256 "8c81732a76b803266a1afc5d20e32611b43bff23076bb39275aa66e7a7f0c3f1"
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
