//
//  LottieLibrary.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 15.02.2025.
//

import SwiftUI

enum LottieLibrary: Int, CaseIterable, Identifiable {

    /// Original AirBnb Lottie library.
    case lottie
    /// Alternative LottieFiles DotLottie library.
    case dotLottie

    var id: Int {
        rawValue
    }

    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .lottie:
            return "lottie-ios"
        case .dotLottie:
            return "dotlottie-ios"
        }
    }
}
