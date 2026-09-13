//
//  LottiePreviewError.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

public enum LottiePreviewError: Error {
    /// DotLottie file does not contain any animation.
    case noAnimations
    /// Animation not decoded.
    case notDecoded
    /// Unknown file format.
    case unknownFileFormat
}
