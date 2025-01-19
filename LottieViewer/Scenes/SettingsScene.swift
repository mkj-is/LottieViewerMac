//
//  SettingsScene.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 18.01.2025.
//

import SwiftUI

struct SettingsScene: Scene {
    var body: some Scene {
        Window("Settings", id: WindowID.settings.rawValue) {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .defaultPosition(.center)
    }
}
