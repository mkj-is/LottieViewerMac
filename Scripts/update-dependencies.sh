#!/bin/bash

set -e

PROJECT_FILE="LottieViewer.xcodeproj/project.pbxproj"

# Get latest release tag from GitHub
get_latest_release() {
    local repo="$1"
    gh release view --repo "$repo" --json tagName -q '.tagName' 2>/dev/null | sed 's/^v//'
}

# Extract packages from project file
echo "Checking for dependency updates..."

# Parse repositoryURL and minimumVersion pairs from project.pbxproj
grep -E "repositoryURL|minimumVersion" "$PROJECT_FILE" | paste - - | while read -r line; do
    repo_url=$(echo "$line" | grep -o 'https://github.com/[^"]*' | sed 's/\.git$//')
    repo="${repo_url#https://github.com/}"
    name="${repo##*/}"
    current_version=$(echo "$line" | grep -o 'minimumVersion = [0-9.]*' | grep -o '[0-9.]*')
    
    if [ -z "$repo" ] || [ -z "$current_version" ]; then
        continue
    fi
    
    latest_version=$(get_latest_release "$repo")
    
    if [ -z "$latest_version" ]; then
        echo "  ERROR: could not fetch latest release for $repo" >&2
        exit 1
    fi
    
    if [ "$latest_version" != "$current_version" ]; then
        echo "  $name: $current_version → $latest_version"
        
        # Update minimumVersion in project.pbxproj for this package
        # Escape special regex characters in name for safe pattern matching
        escaped_name=$(printf '%s\n' "$name" | sed 's/[[\.*^$()+?{|]/\\&/g')
        awk -v old="$current_version" -v new="$latest_version" '
            /repositoryURL.*'"$escaped_name"'/ { found=1 }
            found && /minimumVersion/ { sub(old, new); found=0 }
            { print }
        ' "$PROJECT_FILE" > "${PROJECT_FILE}.tmp" && mv "${PROJECT_FILE}.tmp" "$PROJECT_FILE"
    else
        echo "  $name: $current_version (up to date)"
    fi
done

# Check if any updates were made by comparing with git
if git diff --quiet "$PROJECT_FILE"; then
    echo "No dependency updates found."
    exit 0
fi

echo ""
echo "Resolving updated dependencies..."
xcodebuild -resolvePackageDependencies -project LottieViewer.xcodeproj

echo ""
echo "Building project to update generated files..."
xcodebuild build -project LottieViewer.xcodeproj -scheme LottieViewer -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO | xcpretty || true

# Get current version
CURRENT_VERSION=$(grep -A1 'MARKETING_VERSION' "$PROJECT_FILE" | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | head -1)
echo "Current version: $CURRENT_VERSION"

# Bump patch version
IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
NEW_PATCH=$((patch + 1))
NEW_VERSION="${major}.${minor}.${NEW_PATCH}"
echo "New version: $NEW_VERSION"

sed -i '' "s/MARKETING_VERSION = ${CURRENT_VERSION}/MARKETING_VERSION = ${NEW_VERSION}/g" "$PROJECT_FILE"

echo "Dependencies updated and version bumped to $NEW_VERSION"
