//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import SwiftUI

struct AnimationViewState {
    var showInfo: Bool?
    var configuration = AnimationConfigurationViewState()
}

struct AnimationView: View {
    let animation: LottieAnimation

    @State private var state = AnimationViewState()

    @AppStorage(AppStorageKey.showInfoByDefault.rawValue) private var showInfoByDefault = true

    var body: some View {
        HSplitView {
            LottieView(animation: animation)
                .playing(loopMode: state.configuration.loopMode)
                .animationSpeed(state.configuration.speed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(state.configuration.backgroundColor)

            if showInfo {
                VStack(alignment: .leading) {
                    AnimationConfigurationView(state: $state.configuration)
                    Spacer()
                    InfoView(info: LottieAnimationInfo(animation: animation))
                }
                .padding()
                .frame(minWidth: 150, maxWidth: 300, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Info", systemImage: showInfo ? "info.circle.fill" : "info.circle", action: infoAction)
                    .keyboardShortcut("I", modifiers: .command)
            }
        }
    }

    private var showInfo: Bool {
        state.showInfo ?? showInfoByDefault
    }

    private func infoAction() {
        if state.showInfo == nil {
            state.showInfo = showInfoByDefault
        }
        state.showInfo?.toggle()
    }
}
