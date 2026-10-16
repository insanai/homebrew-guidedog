# Homebrew formula for the Guidedog release binaries, rendered by cargo xtask release formula
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "1.0.0-beta.3"
  license "LGPL-3.0-or-later"

  # Graphviz is linked statically into the programs, so there are no dependencies.

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.3/guidedog-macos-arm64.tar.gz"
      sha256 "30bb05067a7bd7eb1a0765441040b14133a58fbecb83a92f295a1956aa550e67"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.3/guidedog-macos-amd64.tar.gz"
      sha256 "45b8ea49809a68fd4f7f830132c9333f7965424119bb1db454e20ed2b4977284"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.3/guidedog-linux-arm64.tar.gz"
      sha256 "da172b96e98ff00ac48071e9db2073ebd5d5b6e7ef99861c5ae64615fc24b128"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.3/guidedog-linux-amd64.tar.gz"
      sha256 "387649a79809da941c04837f1c0883ced75f58a5374e2d7ff05e2df7d798c6ae"
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
