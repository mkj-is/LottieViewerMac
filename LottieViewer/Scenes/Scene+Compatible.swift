//
//  Scene+CompatibleRestorationBehavior.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 23.02.2025.
//

import SwiftUI

extension Scene {
    func compatibleDisabledRestorationBehavior() -> some Scene {
        if #available(macOS 15.0, *) {
            return self.restorationBehavior(.disabled)
        } else {
            return self
        }
    }
}
