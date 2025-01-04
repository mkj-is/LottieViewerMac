//
//  DocumentView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import Lottie

struct DocumentViewState {
    var info = false
    var animation: LottieAnimation?
    var selection: LottieFileDocument.Animation.ID?
}

struct DocumentView: View {
    @Binding var document: LottieFileDocument

    @State private var state = DocumentViewState()

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
