//
//  AboutWindow.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 15.01.2025.
//

import SwiftUI

struct AboutScene: Scene {
    var body: some Scene {
        Window("About Lottie Viewer", id: WindowID.about.rawValue) {
            AboutView()
        }
        .windowResizability(.contentMinSize)
        .restorationBehavior(.disabled)
        .defaultPosition(.center)
    }
}
