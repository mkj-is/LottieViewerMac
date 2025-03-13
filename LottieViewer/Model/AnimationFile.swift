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
    var data: Data { get }
}

struct LottieAnimationFile: AnimationFile {
    let animation: LottieAnimation
    let data: Data
    let identifiers = [Constant.lottieBundleIdentifier]
}

struct DotLottieAnimationFile: AnimationFile {
    let file: DotLottieFile
    let data: Data

    var identifiers: [String] {
        file.animations.map(\.configuration.id)
    }
}

struct RiveAnimationFile: AnimationFile {
    let file: RiveFile
    let data: Data

    var identifiers: [String] {
        file.artboardNames()
    }
}
