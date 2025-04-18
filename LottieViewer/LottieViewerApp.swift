//
//  LottieViewerApp.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI

enum WindowID: String {
    case about
    case acknowledgements
    case settings
}

@main
struct LottieViewerApp: App {
    @Environment(\.openWindow) private var openWindow

    init() {
        AppInitialization().setup()
    }

    var body: some Scene {
        DocumentGroup(viewing: AnimationFileDocument.self) { file in
            DocumentView(document: file.$document)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Lottie Viewer") {
                    openWindow(id: WindowID.about.rawValue)
                }
            }
        }

        Settings {
            SettingsView()
        }

        AboutScene()
        AcknowledgementsScene()
    }
}
