#!/bin/bash

# Check if output directory is provided
if [ $# -eq 0 ]; then
    echo "Error: Output directory not specified"
    echo "Usage: $0 <output_directory>"
    exit 1
fi

OUTPUT_DIR="$1"

# Get the Lottie version from Package.resolved
LOTTIE_VERSION=$(cat "LottieViewer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" | jq -r '.pins[] | select(.identity=="lottie-ios") | .state.version')

# Generate the Swift constants file
cat > "$OUTPUT_DIR/LottieViewer/Generated/LottieMetadata.swift" << EOF
//
//  LottieMetadata.swift
//  LottieViewer
//
//  Generated automatically - DO NOT EDIT
//

enum LottieMetadata {
    static let version = "$LOTTIE_VERSION"
}
EOF
