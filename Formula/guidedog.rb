# Homebrew formula for the Guidedog release binaries, rendered by cargo xtask release formula
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "1.0.0-beta.8"
  license "LGPL-3.0-or-later"

  # Graphviz is linked statically into the programs, so there are no dependencies.

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.8/guidedog-macos-arm64.tar.gz"
      sha256 "e1a72845305ebc9329c5beabfd30f7360769cb6fbe073bd3250d41d29af63680"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.8/guidedog-macos-amd64.tar.gz"
      sha256 "56bf8220fee2b1c5541a4b8434afe57c9e0d8e5b55e3d3c60d6e22cd66e1a67a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.8/guidedog-linux-arm64.tar.gz"
      sha256 "db9b5e77f71ed614d3ec8a813f9a9a372b4da3d744f2cf0bfa497bcd474d8e2f"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.8/guidedog-linux-amd64.tar.gz"
      sha256 "7d4f6931ca95729877352fc10b33aa903cabcd3cae92459d8b980fe815d9751f"
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
