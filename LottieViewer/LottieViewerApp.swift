//
//  LottieViewerApp.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI

@main
struct LottieViewerApp: App {
    init() {
        AppInitialization().setup()
    }

    var body: some Scene {
        DocumentGroup(viewing: LottieFileDocument.self) { file in
            DocumentView(document: file.$document)
        }
    }
}
