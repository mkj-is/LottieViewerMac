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
    var playing: Bool = true
    var configuration = AnimationConfigurationViewState()
}

struct AnimationView: View {
    let animation: LottieAnimation

    @State private var state = AnimationViewState()

    @ShowInfoAppStorage private var showInfoByDefault

    var body: some View {
        HSplitView {
            LottieView(animation: animation)
                .playbackMode(playbackMode)
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
            ToolbarItem(placement: .principal) {
                Button(state.playing ? "Pause" : "Play", systemImage: state.playing ? "pause.fill" : "play.fill", action: togglePlaying)
                    .keyboardShortcut(.space, modifiers: [])
            }
            ToolbarItem {
                Button("Info", systemImage: showInfo ? "info.circle.fill" : "info.circle", action: toggleInfoView)
                    .keyboardShortcut("I", modifiers: .command)
            }
        }
    }

    private var showInfo: Bool {
        state.showInfo ?? showInfoByDefault
    }

    private var playbackMode: LottiePlaybackMode {
        if state.playing {
            return .playing(.fromProgress(0, toProgress: 1, loopMode: state.configuration.loopMode))
        } else {
            return .paused
        }
    }

    private func togglePlaying() {
        state.playing.toggle()
    }

    private func toggleInfoView() {
        if state.showInfo == nil {
            state.showInfo = showInfoByDefault
        }
        state.showInfo?.toggle()
    }
}
