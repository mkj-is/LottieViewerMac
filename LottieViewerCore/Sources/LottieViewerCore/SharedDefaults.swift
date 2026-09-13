//
//  SharedDefaults.swift
//  LottieViewerCore
//
//  Created by Matěj Kašpar Jirásek on 13.09.2026.
//

import Foundation

public extension UserDefaults {
    /// Defaults shared between the app and the QuickLook extensions.
    ///
    /// All targets are sandboxed, so each one has its own preferences
    /// container. Settings the extensions need to read live in the app group
    /// instead of `standard`.
    ///
    /// Computed rather than stored so the core module stays clean under the
    /// Swift 6 language mode. Foundation caches the suite instance anyway.
    static var shared: UserDefaults {
        UserDefaults(suiteName: Constant.appGroupIdentifier) ?? .standard
    }

    /// Rendering engine used by the app for new windows and by both QuickLook extensions.
    var renderingEngine: LottieLibrary {
        get {
            string(forKey: SharedDefaultsKey.renderingEngine)
                .flatMap(LottieLibrary.init(rawValue:)) ?? .default
        }
        set {
            set(newValue.rawValue, forKey: SharedDefaultsKey.renderingEngine)
        }
    }
}

public enum SharedDefaultsKey {
    public static let renderingEngine = "settings.rendering-engine"
}
