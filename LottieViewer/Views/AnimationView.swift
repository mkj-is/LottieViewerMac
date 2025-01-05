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
    var info: Result<LottieAnimationInfo, Error>?
}

struct AnimationView: View {
    let animation: LottieAnimation

    @State private var state = AnimationViewState()

    var body: some View {
        HSplitView {
            LottieView(animation: animation)
                .playing(loopMode: state.configuration.loopMode)
                .animationSpeed(state.configuration.speed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(state.configuration.backgroundColor)

            if state.showInfo {
                VStack(alignment: .leading) {
                    AnimationConfigurationView(state: $state.configuration)
                    Spacer()
                    if let info = state.info {
                        InfoView(info: info)
                    }
                }
                .padding()
                .frame(minWidth: 250, maxWidth: 300, maxHeight: .infinity)
                .task(priority: .utility, utilityTask)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Info", systemImage: state.showInfo ? "info.circle.fill" : "info.circle", action: infoAction)
                    .keyboardShortcut("I", modifiers: .command)
            }
        }
    }

    private func infoAction() {
        state.showInfo.toggle()
    }

    /// Processes Lottie animation and gets various info and metadata from it.
    ///
    /// `LottieAnimation` has most metadata private. We are encoding it and decoding to our own model,
    ///  so we do not have to access internal variables.
    @Sendable
    private func utilityTask() async {
        guard state.info == nil else {
            return
        }
        state.info = Result {
            let data = try JSONEncoder().encode(animation)
            var info = try JSONDecoder().decode(LottieAnimationInfo.self, from: data)
            info.byteCount = data.count
            return info
        }
    }
}
