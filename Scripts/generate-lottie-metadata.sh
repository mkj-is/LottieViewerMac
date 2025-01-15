#!/bin/bash

# Check if output directory is provided
if [ $# -eq 0 ]; then
    echo "Error: BUILD_DIR data directory not specified"
    echo "Usage: $0 <output_directory>"
    exit 1
fi

BUILD_DIR="$1"

# Get the Lottie version from Package.resolved
LOTTIE_VERSION=$(cat "LottieViewer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" | jq -r '.pins[] | select(.identity=="lottie-ios") | .state.version')

# Find the LICENSE file in SPM cache
LOTTIE_LICENSE_PATH="${BUILD_DIR}/../../SourcePackages/checkouts/lottie-ios/LICENSE"

LOTTIE_LICENSE=$(cat "$LOTTIE_LICENSE_PATH" | sed ':a;N;$!ba;s/\n/\\n/g')

# Generate the Swift constants file
cat > "LottieViewer/Generated/LottieMetadata.swift" << EOF
//
//  LottieMetadata.swift
//  LottieViewer
//
//  Generated automatically - DO NOT EDIT
//

enum LottieMetadata {
    static let version = "$LOTTIE_VERSION"
    static let license = """
$LOTTIE_LICENSE
"""
}
EOF
