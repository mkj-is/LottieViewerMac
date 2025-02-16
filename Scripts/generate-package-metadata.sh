#!/bin/bash

# Check if output directory is provided
if [ $# -eq 0 ]; then
    echo "Error: BUILD_DIR data directory not specified"
    echo "Usage: $0 <output_directory>"
    exit 1
fi

BUILD_DIR="$1"

JSON_FILE="LottieViewer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

# Output Swift file
SWIFT_FILE="LottieViewer/Generated/ResolvedPackages.swift"

# Find the LICENSE file in SPM cache
LOTTIE_LICENSE_PATH="${BUILD_DIR}/../../SourcePackages/checkouts/lottie-ios/LICENSE"
DOTLOTTIE_LICENSE_PATH="${BUILD_DIR}/../../SourcePackages/checkouts/dotlottie-ios/LICENSE"

LOTTIE_LICENSE=$(cat "$LOTTIE_LICENSE_PATH" | sed ':a;N;$!ba;s/\n/\\n/g')
DOTLOTTIE_LICENSE=$(cat "$LOTTIE_LICENSE_PATH" | sed ':a;N;$!ba;s/\n/\\n/g')

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

    cat <<EOF >> "$SWIFT_FILE"
        "$IDENTITY": Package(
            location: URL(string: "$LOCATION")!,
            version: "$VERSION"
        ),
EOF
done

# Close dictionary and struct
cat <<EOF >> "$SWIFT_FILE"
    ]
}
EOF
