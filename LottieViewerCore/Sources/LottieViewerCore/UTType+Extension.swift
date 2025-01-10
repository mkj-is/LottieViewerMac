//
//  UTType+Extension.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

import UniformTypeIdentifiers

public extension UTType {
    static var dotLottie: UTType {
        UTType(importedAs: "io.dotlottie.lottie")
    }

    static var lottie: UTType {
        UTType(importedAs: "io.airbnb.lottie")
    }
}
