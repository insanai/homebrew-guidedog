# Guidedog Homebrew tap

We install [Guidedog](https://github.com/insanai/guidedog), a documentation tool that builds HTML sites and PDF books from reStructuredText and Markdown.

```sh
brew install insanai/guidedog/guidedog
guidedog --version
```

Homebrew selects the published Apple silicon or Intel macOS archive and checks its SHA-256 before installing it.
The formula also supports the published Linux arm64 and amd64 archives.
The release installs one executable, `guidedog`.
Its linked plugins add `guidedog dsc`, `guidedog publish pages` and `guidedog pages` maintenance commands.
The `gd-graphdog` library encapsulates Graphviz inside Guidedog.
No additional CLI, Python environment, external Typst compiler or separate Graphviz installation is needed.

```sh
brew update
brew upgrade insanai/guidedog/guidedog
brew test insanai/guidedog/guidedog
```

The formula test creates a project and builds both HTML and PDF.
Notices and the source manifest are installed beside the binary in Homebrew's documentation folder.
Guidedog is licensed under LGPL-3.0-or-later, with the Graphviz additional permission described in the release notices.

## Maintenance

`Formula/guidedog.rb` is copied unchanged from the published Guidedog release.
The Update workflow checks published releases every hour, including beta versions, and selects the greatest version.
We can also run it manually with an explicit tag.
It verifies the formula and checksum manifest against GitHub's asset digests, then checks the formula's version, archive URLs and four archive checksums against that manifest.
It installs and tests the candidate on Apple silicon and Intel macOS before committing an update.
The normal Test workflow checks both architectures as well.

The updater uses this repository's `GITHUB_TOKEN`; no personal access token or cross-repository write access is required.
A failed download, verification or test leaves the tracked formula unchanged.
Upstream release qualification remains responsible for the full engine and platform test suites.

To update locally, we install GitHub CLI, `jq` and Ruby, then run:

```sh
scripts/update-formula.sh
```

We review and test the result before committing it.
The script accepts an optional release tag such as `v1.0.0-beta.1`; it rejects downgrades.
It never changes or uploads upstream release assets.

Documentation: <https://insanai.github.io/guidedog/>

The new Rust project is `insanai/guidedog`; the earlier project is now named `insanai/guidedog_odin`.
Scheduled updates include `v1.0.0-beta.1` and later beta versions, then follow the stable release when its version is greater.
