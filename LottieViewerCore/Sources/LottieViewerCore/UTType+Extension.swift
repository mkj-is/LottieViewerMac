//
//  UTType+Extension.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

import UniformTypeIdentifiers

public extension UTType {
    static let lottie: UTType = .json
    /// The type IANA registered for `video/lottie+json` in February 2025.
    ///
    /// macOS has no built-in identifier for `lot`, so without this declaration
    /// such files fall back to `public.data` and never reach the app or the
    /// Quick Look extensions. It conforms to `public.json`, which means
    /// `conforms(to: .lottie)` covers both spellings of a Lottie JSON file.
    static let lot = UTType(importedAs: "io.lottie.lot", conformingTo: .json)
    static let dotLottie = UTType(importedAs: "io.dotlottie.lottie", conformingTo: .zip)
    static let rive = UTType(importedAs: "app.rive.rive-file", conformingTo: .data)
}
