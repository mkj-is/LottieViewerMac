//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import SwiftUI

struct AnimationViewState {
    var showInfo: Bool = false
    var configuration = AnimationConfigurationViewState()
}

struct AnimationView: View {
    let animation: LottieAnimation

    @State private var state = AnimationViewState()

    var body: some View {
        HSplitView {
            LottieView(animation: animation)
                .playing(loopMode: .loop)
                .animationSpeed(state.configuration.speed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if state.showInfo {
                AnimationConfigurationView(state: $state.configuration)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Info", systemImage: state.showInfo ? "info.circle.fill" : "info.circle", action: infoAction)
            }
        }
    }

    private func infoAction() {
        state.showInfo.toggle()
    }
}
