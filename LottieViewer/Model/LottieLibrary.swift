//
//  LottieLibrary.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 15.02.2025.
//

import LottieViewerCore

/// Package metadata for the rendering engines.
///
/// Kept in the app target because `ResolvedPackages` is generated into it by
/// `Scripts/generate-package-metadata.sh` and is not visible to the extensions.
extension LottieLibrary {
    var description: String {
        if let package {
            return name + " " + package.version
        }
        return name
    }

    var package: Package? {
        ResolvedPackages.dictionary[rawValue]
    }
}
