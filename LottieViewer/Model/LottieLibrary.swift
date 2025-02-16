//
//  LottieLibrary.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 15.02.2025.
//

import SwiftUI

enum LottieLibrary: String, CaseIterable, Identifiable {

    /// Original AirBnb Lottie library.
    case lottie = "lottie-ios"
    /// Alternative LottieFiles DotLottie library.
    case dotLottie = "dotlottie-ios"

    var id: String {
        rawValue
    }

    var name: LocalizedStringKey {
        switch self {
        case .lottie:
            return "Lottie"
        case .dotLottie:
            return "DotLottie"
        }
    }

    var package: Package? {
        ResolvedPackages.dictionary[rawValue]
    }
}
