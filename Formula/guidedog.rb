# Homebrew formula for the Guidedog release binaries, rendered by tools/release/formula.sh
# and attached to each GitHub release as guidedog.rb.
class Guidedog < Formula
  desc "Builds HTML documentation sites and PDF books from reStructuredText and Markdown"
  homepage "https://github.com/insanai/guidedog"
  version "0.2.0"
  license "AGPL-3.0-or-later"

  on_macos do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.0/guidedog-macos-arm64.tar.gz"
      sha256 "df771e3ecdcd9be082b7a89de07f32ed1139ffee8de2190bf6ed50d46a9c9c2e"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.0/guidedog-macos-amd64.tar.gz"
      sha256 "27e4d59d3eef24c7d1ae3189332215e190204176629025d71e1e21ee7581400a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.0/guidedog-linux-arm64.tar.gz"
      sha256 "3c01a0c18d7c199704d3b2fb9b204aab6a0db0c5801b5dbc402bf9c696d0c21e"
    end
    on_intel do
      url "https://github.com/insanai/guidedog/releases/download/v0.2.0/guidedog-linux-amd64.tar.gz"
      sha256 "4aa06dc1625930dc659c3456ab878ed1881307f8bf703b4e0bf673958cacd0f4"
    end
  end

  def install
    bin.install "guidedog"
    doc.install "NOTICE", "CHANGELOG.md", "SOURCE.txt", "guidedog.build.json"
  end

  test do
    assert_match "guidedog #{version}", shell_output("#{bin}/guidedog --version")
    system bin/"guidedog", "quickstart", "docs", "-q", "-p", "Demo", "-a", "Homebrew"
    system bin/"guidedog", "build", "html", "docs", "-W"
    assert_path_exists testpath/"docs/_build/html/index.html"
    system bin/"guidedog", "build", "pdf", "docs", "-W"
    assert_path_exists testpath/"docs/_build/pdf/demo-en.pdf"
  end
end
