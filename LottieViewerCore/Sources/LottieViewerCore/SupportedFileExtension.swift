//
//  SupportedFileExtension.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

public enum SupportedFileExtension: String {
    case lottie = "json"
    /// The same format as ``lottie``, under the extension IANA registered for
    /// `video/lottie+json` in February 2025. It is supplementary, files using
    /// the historical `json` extension stay just as valid.
    case lot
    case dotLottie = "lottie"
    case rive = "riv"

    /// Whether the file holds raw Lottie JSON, under either of its extensions.
    public var isLottieJSON: Bool {
        self == .lottie || self == .lot
    }

    /// Matches a URL's `pathExtension`, which carries no case guarantee.
    public init?(pathExtension: String) {
        self.init(rawValue: pathExtension.lowercased())
    }
}
