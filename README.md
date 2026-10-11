# Guidedog Homebrew tap

Install [Guidedog](https://github.com/insanai/guidedog), a native documentation CLI
that builds HTML sites and PDF books from reStructuredText and Markdown.

```sh
brew install insanai/guidedog/guidedog
guidedog --version
```

Homebrew selects the published Apple silicon or Intel macOS archive and checks its
SHA-256 before installing it. The formula also supports the published Linux arm64
and amd64 archives. No Odin compiler, Python environment, external Typst compiler,
or separate Graphviz installation is needed.

```sh
brew update
brew upgrade insanai/guidedog/guidedog
brew test insanai/guidedog/guidedog
```

The formula test creates a project and builds both HTML and PDF. Notices and the
source manifest are installed beside the binary in Homebrew's documentation folder.
Guidedog is licensed under AGPL-3.0-or-later, with the Graphviz additional permission
described in the release notices.

## Maintenance

`Formula/guidedog.rb` is copied unchanged from the published Guidedog release.
The Update workflow checks the latest stable release daily, or can be run manually.
It verifies the formula and checksum manifest against GitHub's asset digests, then
checks the formula's version, archive URLs, and four archive checksums against that
manifest. It installs and tests the candidate on Apple silicon before committing
an update. The normal Test workflow also checks Apple silicon and Intel macOS.

The updater uses this repository's `GITHUB_TOKEN`; no personal access token or
cross-repository write access is required. A failed download, verification, or test
leaves the tracked formula unchanged. Upstream release qualification remains
responsible for the full engine and platform test suites.

To update locally, install GitHub CLI and `jq`, then run:

```sh
scripts/update-formula.sh
```

Review and test the result before committing it. The script accepts an optional
stable release tag such as `v0.2.0`; it rejects downgrades. It never changes or
uploads upstream release assets.

Documentation: <https://insanai.github.io/guidedog/>
