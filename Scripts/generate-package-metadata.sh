#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Error: BUILD_DIR or BUILT_PRODUCTS_DIR directory not specified"
    echo "Usage: $0 <BUILD_DIR> <BUILT_PRODUCTS_DIR>"
    exit 1
fi

BUILD_DIR="$1"
BUILT_PRODUCTS_DIR="$2"

# Path during archive
ARCHIVE_SPM_DIR="${BUILT_PRODUCTS_DIR}/SwiftPackageProducts"

# Path during build
BUILD_SPM_DIR="${BUILD_DIR%/Build/*}/SourcePackages/checkouts"


if [ -d "$ARCHIVE_SPM_DIR" ]; then
    TARGET_SPM_DIR="$ARCHIVE_SPM_DIR"
else
    TARGET_SPM_DIR="$BUILD_SPM_DIR"
fi

JSON_FILE="LottieViewer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

# Output Swift file
SWIFT_FILE="LottieViewer/Generated/ResolvedPackages.swift"

# Generate the Swift constants file
cat <<EOF > "$SWIFT_FILE"
//
//  ResolvedPackages.swift
//  LottieViewer
//
//  Generated automatically - DO NOT EDIT
//

import Foundation

enum ResolvedPackages {
    static let dictionary: [String: Package] = [
EOF

# Extract and iterate over the pins array
jq -c '.pins[]' "$JSON_FILE" | while read -r pin; do
    IDENTITY=$(echo "$pin" | jq -r '.identity')
    LOCATION=$(echo "$pin" | jq -r '.location')
    VERSION=$(echo "$pin" | jq -r '.state.version')

    # Construct the license path based on the identity
    LICENSE_PATH="${TARGET_SPM_DIR}/${IDENTITY}/LICENSE"
    LICENSE=$(sed ':a;N;$!ba;s/\n/\\n/g' "$LICENSE_PATH")

    cat <<EOF >> "$SWIFT_FILE"
        "$IDENTITY": Package(
            location: URL(string: "$LOCATION")!,
            version: "$VERSION",
            license: """
$LICENSE
"""
        ),
EOF
done

# Close dictionary and struct
cat <<EOF >> "$SWIFT_FILE"
    ]
}
EOF
