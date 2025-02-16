//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import DotLottie
import SwiftUI

struct AnimationViewState {
    var showInfo: Bool?
    var playing: Bool = true
    var configuration = AnimationConfigurationViewState()
}

struct AnimationView: View {
    let animation: LottieFileDocument.Animation
    let id: String?

    @State private var state = AnimationViewState()

    @Environment(\.documentConfiguration) private var documentConfiguration

    @ShowInfoAppStorage private var showInfoByDefault

    var body: some View {
        HSplitView {
            lottieLibraryView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(state.configuration.backgroundColor)

            if showInfo {
                VStack(alignment: .leading) {
                    AnimationConfigurationView(state: $state.configuration)
                    Spacer()
                    InfoView(info: LottieAnimationInfo(animation: animation.animation))
                }
                .padding()
                .frame(minWidth: 150, maxWidth: 300, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(
                    state.playing ? "Pause" : "Play",
                    systemImage: state.playing ? "pause.fill" : "play.fill",
                    action: togglePlaying
                )
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

    @ViewBuilder
    private var lottieLibraryView: some View {
        switch state.configuration.library {
        case .lottie:
            LottieView(animation: animation.animation)
                .configure(configure)
                .playbackMode(playbackMode)
                .animationSpeed(state.configuration.speed)
        case .dotLottie:
            dotLottieAnimation?.view()
        }
    }

    // MARK: - Lottie configuration

    private var playbackMode: LottiePlaybackMode {
        if state.playing {
            return .playing(.fromProgress(0, toProgress: 1, loopMode: state.configuration.loopMode))
        } else {
            return .paused
        }
    }

    private func configure(view: LottieAnimationView) {
        if let imageProvider = animation.configuration?.imageProvider {
            view.imageProvider = imageProvider
        }
    }

    // MARK: - DotLottie configuration

    private var dotLottieAnimation: DotLottieAnimation? {
        guard let fileURL = documentConfiguration?.fileURL, let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        let configuration = AnimationConfig(
            autoplay: state.playing,
            loop: state.configuration.loopMode == .loop,
            mode: state.configuration.loopMode == .autoReverse ? .bounce : .forward,
            speed: Float(state.configuration.speed),
            backgroundColor: CIColor(color: NSColor(state.configuration.backgroundColor)).flatMap { CIImage(color: $0) }
        )
        if fileURL.pathExtension == "json", let data = String(data: data, encoding: .utf8) {
            return DotLottieAnimation(animationData: data, config: configuration)
        } else {
            let animation =  DotLottieAnimation(dotLottieData: data, config: configuration)
            if let id {
                try? animation.loadAnimationById(id)
            }
            return animation
        }
    }

    // MARK: - Actions

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
