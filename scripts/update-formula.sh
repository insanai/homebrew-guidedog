#!/bin/bash
# Import the verified formula from a published stable Guidedog release.
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
    [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    gh api "repos/$repository/releases/tags/$1" > "$work/release.json"
else
    gh api "repos/$repository/releases/latest" > "$work/release.json"
fi
jq -e '.draft == false and .prerelease == false' "$work/release.json" >/dev/null
tag=$(jq -r .tag_name "$work/release.json")
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
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
current=$(sed -n 's/^  version "\([0-9.]*\)"$/\1/p' Formula/guidedog.rb)
[[ "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
awk -v old="$current" -v new="$version" 'BEGIN {
    split(old, a, "."); split(new, b, ".")
    for (i=1; i<=3; i++) {
        if (b[i]+0 > a[i]+0) exit 0
        if (b[i]+0 < a[i]+0) exit 1
    }
}' || { echo "Refusing downgrade from $current to $version." >&2; exit 1; }

cp "$work/guidedog.rb" Formula/guidedog.rb
echo "Verified Guidedog $version."
