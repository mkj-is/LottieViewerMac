//
//  LottieLibrary.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 15.02.2025.
//

/// Library used to render Lottie and DotLottie animations.
///
/// Lives in the core module so that the QuickLook extensions can read the
/// engine preference. Package metadata lives in the app target, which is the
/// only one with the generated `ResolvedPackages`.
public enum LottieLibrary: String, CaseIterable, Identifiable, Sendable {

    /// Original AirBnb Lottie library.
    case lottie = "lottie-ios"
    /// Alternative LottieFiles DotLottie library.
    case dotLottie = "dotlottie-ios"

    /// Engine used until the user picks another one.
    public static let `default`: LottieLibrary = .lottie

    public var id: String {
        rawValue
    }

    public var name: String {
        switch self {
        case .lottie:
            return "Lottie"
        case .dotLottie:
            return "DotLottie"
        }
    }
}
