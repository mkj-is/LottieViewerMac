//
//  LottieViewerApp.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI

@main
struct LottieViewerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: LottieViewerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
