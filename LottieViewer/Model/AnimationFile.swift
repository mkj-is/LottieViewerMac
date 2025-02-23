//
//  AnimationModel.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 23.02.2025.
//

import LottieViewerCore
@preconcurrency import Lottie
@preconcurrency import RiveRuntime

protocol AnimationFile: Sendable {
    var identifiers: [String] { get }
}

struct LottieAnimationFile: AnimationFile {
    let animation: LottieAnimation
    let identifiers = [Constant.lottieBundleIdentifier]
}

struct DotLottieAnimationFile: AnimationFile {
    let file: DotLottieFile

    var identifiers: [String] {
        file.animations.map(\.configuration.id)
    }
}

struct RiveAnimationFile: AnimationFile {
    let file: RiveFile

    var identifiers: [String] {
        file.artboardNames()
    }
}
