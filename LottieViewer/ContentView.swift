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
        if let firstAnimation = document.animations.first?.animation {
            if document.animations.count > 1 {
                NavigationSplitView {
                    List(document.animations, selection: $state.selection) { animation in
                        Text(animation.id)
                    }
                } detail: {
                    LottieView(animation: selectedAnimation ?? firstAnimation)
                        .playing(loopMode: .loop)
                }
            } else {
                LottieView(animation: firstAnimation)
                    .playing(loopMode: .loop)
            }
        } else {
            Text("No animations included in this file.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var selectedAnimation: LottieAnimation? {
        document.animations.first(where: { animation in
            animation.id == state.selection
        })?.animation
    }

    private func infoAction() {
        state.info.toggle()
    }
}
