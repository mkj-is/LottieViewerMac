//
//  UTType+Extension.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

import UniformTypeIdentifiers

public extension UTType {
    static let dotLottie = UTType(importedAs: "io.dotlottie.lottie")
    static let lottie: UTType = .json
}
