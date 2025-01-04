//
//  ContentView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import Lottie

struct ContentViewState {
    var info = false
    var animation: LottieAnimation?
    var selection: LottieViewerDocument.Animation.ID?
}

struct ContentView: View {
    @Binding var document: LottieViewerDocument

    @State private var state = ContentViewState()

    var body: some View {
        NavigationSplitView {
            List(document.animations, selection: $state.selection) { animation in
                Text(animation.id)
            }
        } detail: {
            if let animation = document.animations.first(where: { animation in
                animation.id == state.selection
            }) {
                LottieView(animation: animation.animation)
                    .playing(loopMode: .loop)
            }
        }
    }

    private func infoAction() {
        state.info.toggle()
    }
}
