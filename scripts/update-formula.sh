#!/bin/bash
# Import the verified formula from a published Guidedog release.
set -euo pipefail
cd "$(dirname "$0")/.."
repository=insanai/guidedog
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ "$#" -gt 1 ]; then
    echo "Usage: scripts/update-formula.sh [vVERSION]" >&2
    exit 1
fi
if [ "$#" -eq 1 ]; then
    [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+(\.[0-9A-Za-z]+)*)?$ ]]
    gh api "repos/$repository/releases/tags/$1" > "$work/release.json"
else
    gh api "repos/$repository/releases?per_page=100" \
        --jq '[.[] | select(.draft == false)]' > "$work/releases.json"
    ruby -rjson -e '
        releases = JSON.parse(File.read(ARGV[0])).select { |r|
            r.fetch("tag_name").match?(/\Av[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+(\.[0-9A-Za-z]+)*)?\z/)
        }
        selected = releases.max_by { |r| Gem::Version.new(r.fetch("tag_name").delete_prefix("v")) }
        puts JSON.generate(selected) if selected
    ' "$work/releases.json" > "$work/release.json"
    if [ ! -s "$work/release.json" ]; then
        echo "No published Guidedog release yet; keeping the current formula."
        exit 0
    fi
fi
jq -e '.draft == false' "$work/release.json" >/dev/null
tag=$(jq -r .tag_name "$work/release.json")
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+(\.[0-9A-Za-z]+)*)?$ ]]
version=${tag#v}

for name in guidedog.rb SHA256SUMS; do
    digest=$(jq -er --arg name "$name" \
        '[.assets[] | select(.name == $name)] | select(length == 1) | .[0].digest' \
        "$work/release.json")
    [[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]]
    gh release download "$tag" --repo "$repository" --pattern "$name" --dir "$work"
    actual=$(shasum -a 256 "$work/$name")
    [ "${actual%% *}" = "${digest#sha256:}" ]
done

checksum() {
    awk -v name="$1" '$2 == name {print $1; count++} END {if (count != 1) exit 1}' \
        "$work/SHA256SUMS"
}
actual=$(shasum -a 256 "$work/guidedog.rb")
[ "${actual%% *}" = "$(checksum guidedog.rb)" ]
grep -Fxq "  version \"$version\"" "$work/guidedog.rb"
for platform in macos-arm64 macos-amd64 linux-arm64 linux-amd64; do
    archive=guidedog-$platform.tar.gz
    expected=$(checksum "$archive")
    [[ "$expected" =~ ^[a-f0-9]{64}$ ]]
    asset_digest=$(jq -er --arg name "$archive" \
        '[.assets[] | select(.name == $name)] | select(length == 1) | .[0].digest' \
        "$work/release.json")
    [ "$asset_digest" = "sha256:$expected" ]
    # Match adjacent URL/checksum lines, without evaluating downloaded Ruby.
    awk -v url="https://github.com/$repository/releases/download/$tag/$archive" \
        -v sum="$expected" '
        $1 == "url" && $2 == "\"" url "\"" {
            if (getline > 0 && $1 == "sha256" && $2 == "\"" sum "\"") found++
        }
        END {if (found != 1) exit 1}
    ' "$work/guidedog.rb"
done

# Numeric semantic-version comparison; do not silently roll back an installation.
current=$(sed -n 's/^  version "\([^"]*\)"$/\1/p' Formula/guidedog.rb)
# Ruby is part of Homebrew; Gem::Version orders beta versions before the final release.
ruby -e 'exit(Gem::Version.new(ARGV[1]) >= Gem::Version.new(ARGV[0]) ? 0 : 1)' \
    "$current" "$version" || {
    echo "Refusing downgrade from $current to $version." >&2
    exit 1
}

cp "$work/guidedog.rb" Formula/guidedog.rb
echo "Verified Guidedog $version."
