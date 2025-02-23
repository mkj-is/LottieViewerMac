//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import DotLottie
import SwiftUI
import RiveRuntime

private struct AnimationViewState {
    var showInfo: Bool?
    var playing: Bool = true
    var configuration = AnimationConfigurationViewState()

    var dotLottieParseTime: TimeInterval?
    var dotLottieAnimation: DotLottieAnimation?
}

struct AnimationView: View {
    let animationFile: AnimationFile
    let id: String?

    @State private var state = AnimationViewState()

    @Environment(\.documentConfiguration) private var documentConfiguration

    @ShowInfoAppStorage private var showInfoByDefault

    var body: some View {
        HSplitView {
            animationRenderingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(state.configuration.backgroundColor)

            if showInfo {
                VStack(alignment: .leading) {
                    AnimationConfigurationView(isLottie: isLottie, state: $state.configuration)
                    Spacer()
                    if let lottieAnimation {
                        InfoView(info: LottieAnimationInfo(animation: lottieAnimation))
                            .transformEnvironment(\.parseTime) { parseTime in
                                if state.configuration.library == .dotLottie {
                                    parseTime = state.dotLottieParseTime
                                } else {
                                    parseTime = parseTime
                                }
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

    @ViewBuilder
    private var animationRenderingView: some View {
        switch animationFile {
        case let animationFile as RiveAnimationFile:
            riveViewModel(model: RiveModel(riveFile: animationFile.file)).view()
        case let animationFile as LottieAnimationFile:
            lottieLibraryView(animation: animationFile.animation)
        case let animationFile as DotLottieAnimationFile:
            if let id, let animation = animationFile.file.animations.first(where: { $0.configuration.id == id }) {
                lottieLibraryView(animation: animation.animation, configuration: animation.configuration)
            } else if let animation = animationFile.file.animations.first {
                lottieLibraryView(animation: animation.animation, configuration: animation.configuration)
            } else {
                Text("No animation found.")
            }
        default:
            Text("Unknown animation file.")
        }
    }

    private func riveViewModel(model: RiveModel) -> RiveViewModel {
        let viewModel = RiveViewModel(model, fit: .contain, artboardName: id)
        switch state.configuration.loopMode {
        case .autoReverse:
            viewModel.play(loop: .pingPong)
        case .playOnce:
            viewModel.play(loop: .oneShot)
        case .loop:
            viewModel.play(loop: .loop)
        default:
            break
        }
        return viewModel
    }

    @ViewBuilder
    private func lottieLibraryView(animation: LottieAnimation, configuration: DotLottieConfiguration? = nil) -> some View {
        switch state.configuration.library {
        case .lottie:
            LottieView(animation: animation)
                .configure { configure(view: $0, configuration: configuration)}
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

    private var showInfo: Bool {
        state.showInfo ?? showInfoByDefault
    }

    private var isLottie: Bool {
        animationFile is LottieAnimationFile || animationFile is DotLottieAnimationFile
    }

    // MARK: - Lottie configuration

    private var lottieAnimation: LottieAnimation? {
        switch animationFile {
        case let animationFile as LottieAnimationFile:
            return animationFile.animation
        case let animationFile as DotLottieAnimationFile:
            if let id, let animation = animationFile.file.animations.first(where: { $0.configuration.id == id }) {
                return animation.animation
            } else if let animation = animationFile.file.animations.first {
                return animation.animation
            }
            return nil
        default:
            return nil
        }
    }

    private var dotLottieConfiguration: DotLottieConfiguration? {
        guard case let animationFile as DotLottieAnimationFile = animationFile else {
            return nil
        }
        if let id, let animation = animationFile.file.animations.first(where: { $0.configuration.id == id }) {
            return animation.configuration
        } else if let animation = animationFile.file.animations.first {
            return animation.configuration
        }
        return nil
    }

    private var playbackMode: LottiePlaybackMode {
        if state.playing {
            return .playing(.fromProgress(0, toProgress: 1, loopMode: state.configuration.loopMode))
        } else {
            return .paused
        }
    }

    private func configure(view: LottieAnimationView, configuration: DotLottieConfiguration?) {
        if let imageProvider = configuration?.imageProvider {
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
