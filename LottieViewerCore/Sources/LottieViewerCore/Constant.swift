//
//  Constant.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 12.01.2025.
//

import Foundation

public enum Constant {
    public static let githubUrl = URL(string: "https://github.com/mkj-is/LottieViewerMac")!
    public static let lottieBundleIdentifier = "io.airbnb.lottie"
    public static let loggingCategory = "LottieLogger"
    /// Matches `$(TeamIdentifierPrefix)group.dev.mkj.LottieViewer` in the entitlements files.
    /// macOS requires app group identifiers to be prefixed with the team identifier.
    public static let appGroupIdentifier = "QLPB86L68N.group.dev.mkj.LottieViewer"
}
