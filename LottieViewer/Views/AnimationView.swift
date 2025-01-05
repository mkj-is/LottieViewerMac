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

            if state.showInfo {
                VStack {
                    AnimationConfigurationView(state: $state.configuration)
                    Spacer()
                    if let info = state.info {
                        InfoView(info: info)
                    }
                }
                .task(priority: .utility, utilityTask)
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
