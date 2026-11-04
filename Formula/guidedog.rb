# Homebrew formula for the Guidedog release binaries, rendered by cargo xtask release formula
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "1.0.0-beta.12"
  license "LGPL-3.0-or-later"

  # Graphviz is linked statically into the programs, so there are no dependencies.

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.12/guidedog-macos-arm64.tar.gz"
      sha256 "b8a77f3c89be48553f76d34b383351a4a57624ec4d167f10fe8ea9470bb494d0"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.12/guidedog-macos-amd64.tar.gz"
      sha256 "21724be822abac3cf92248a39519e67a3f6e453223f934243098b8b79a829476"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.12/guidedog-linux-arm64.tar.gz"
      sha256 "2375df6d8c6f28e047d0e6c22f1e0f3918a3dc0e5073972118e21091a4db84a1"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v1.0.0-beta.12/guidedog-linux-amd64.tar.gz"
      sha256 "26d8abb12889714e1f2840a372851e2582a5fc842dcc18ee0450371581519fba"
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
