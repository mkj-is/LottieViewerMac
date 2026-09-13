#!/bin/bash

set -e
set -o pipefail

PROJECT_FILE="LottieViewer.xcodeproj/project.pbxproj"

# project.pbxproj is a plist, so plutil can read it structurally. There is no
# OpenStep writer, so the edits below stay textual; plutil is only used to read.
project_json() {
    plutil -convert json -o - "$PROJECT_FILE"
}

# Get latest release tag from GitHub
get_latest_release() {
    local repo="$1"
    gh release view --repo "$repo" --json tagName -q '.tagName' 2>/dev/null | sed 's/^v//'
}

# True when $1 is strictly newer than $2, so an upstream re-tag or downgrade
# does not read as an update the way string inequality did.
version_gt() {
    [ "$(jq -n --arg a "$1" --arg b "$2" \
        '($a|split(".")|map(tonumber? // 0)) > ($b|split(".")|map(tonumber? // 0))')" = "true" ]
}

echo "Checking for dependency updates..."

packages=$(project_json | jq -r '
    .objects[]
    | select(.isa == "XCRemoteSwiftPackageReference")
    | [.repositoryURL, .requirement.minimumVersion]
    | @tsv
')

updated=0

# Skips both the blank line an empty list produces and any package pinned to a
# branch or revision rather than a version.
while IFS=$'\t' read -r repo_url current_version; do
    [ -n "$current_version" ] || continue

    repo="${repo_url#https://github.com/}"
    repo="${repo%.git}"
    name="${repo##*/}"

    latest_version=$(get_latest_release "$repo" || true)

    if [ -z "$latest_version" ]; then
        echo "  ERROR: could not fetch latest release for $repo" >&2
        exit 1
    fi

    if version_gt "$latest_version" "$current_version"; then
        echo "  $name: $current_version → $latest_version"

        # Anchor on the whole repositoryURL line: index() matches literally, so
        # lottie-ios cannot also match the dotlottie-ios entry.
        awk -v url_line="repositoryURL = \"$repo_url\";" -v new="$latest_version" '
            index($0, url_line) { found = 1 }
            found && /minimumVersion = / {
                sub(/minimumVersion = [^;]*;/, "minimumVersion = " new ";")
                found = 0
            }
            { print }
        ' "$PROJECT_FILE" > "${PROJECT_FILE}.tmp" && mv "${PROJECT_FILE}.tmp" "$PROJECT_FILE"

        updated=1
    else
        echo "  $name: $current_version (up to date)"
    fi
done <<< "$packages"

if [ "$updated" -eq 0 ]; then
    echo "No dependency updates found."
    exit 0
fi

echo ""
echo "Resolving updated dependencies..."
xcodebuild -resolvePackageDependencies -project LottieViewer.xcodeproj

echo ""
echo "Building project to update generated files..."
if ! xcodebuild build -project LottieViewer.xcodeproj -scheme LottieViewer -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO; then
    echo "  WARNING: build failed, generated files may be stale" >&2
fi

# Get current version
CURRENT_VERSION=$(project_json | jq -r 'first(.objects[]
    | select(.isa == "XCBuildConfiguration")
    | .buildSettings.MARKETING_VERSION
    | select(. != null))')
echo "Current version: $CURRENT_VERSION"

# Bump patch version
IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
NEW_PATCH=$((patch + 1))
NEW_VERSION="${major}.${minor}.${NEW_PATCH}"
echo "New version: $NEW_VERSION"

# Escape the dots so the current version is not matched as a regex wildcard
sed -i '' "s/MARKETING_VERSION = ${CURRENT_VERSION//./\\.};/MARKETING_VERSION = ${NEW_VERSION};/g" "$PROJECT_FILE"

echo "Dependencies updated and version bumped to $NEW_VERSION"
