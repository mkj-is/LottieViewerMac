//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import DotLottie
import SwiftUI

private struct AnimationViewState {
    var showInfo: Bool?
    var playing: Bool = true
    var configuration = AnimationConfigurationViewState()

    var dotLottieParseTime: TimeInterval?
    var dotLottieAnimation: DotLottieAnimation?
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
                        .transformEnvironment(\.parseTime) { parseTime in
                            if state.configuration.library == .dotLottie {
                                parseTime = state.dotLottieParseTime
                            } else {
                                parseTime = parseTime
                            }
                        }
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
            if let animation = state.dotLottieAnimation {
                animation.view()
                    .task(id: state.configuration.library, priority: .userInitiated) {
                        loadDotLottieAnimation()
                    }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task(id: state.configuration.library, priority: .userInitiated) {
                        loadDotLottieAnimation()
                    }
            }
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

    private func loadDotLottieAnimation() {
        guard state.configuration.library == .dotLottie else {
            return
        }
        guard let fileURL = documentConfiguration?.fileURL, let data = try? Data(contentsOf: fileURL) else {
            return
        }
        let configuration = AnimationConfig(
            autoplay: state.playing,
            loop: state.configuration.loopMode == .loop,
            mode: state.configuration.loopMode == .autoReverse ? .bounce : .forward,
            speed: Float(state.configuration.speed),
            backgroundColor: CIColor(color: NSColor(state.configuration.backgroundColor)).flatMap { CIImage(color: $0) }
        )

        let parsingStartTime: Date = .now

        if fileURL.pathExtension == "json", let data = String(data: data, encoding: .utf8) {
            state.dotLottieAnimation = DotLottieAnimation(animationData: data, config: configuration)
        } else {
            let animation =  DotLottieAnimation(dotLottieData: data, config: configuration)
            if let id {
                try? animation.loadAnimationById(id)
            }
            state.dotLottieAnimation = animation
        }

        state.dotLottieParseTime = Date.now.timeIntervalSince(parsingStartTime)
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
