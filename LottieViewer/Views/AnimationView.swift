//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import DotLottie
import Lottie
import LottieViewerCore
import RiveRuntime
import SwiftUI

/// Animation the DotLottie player should have loaded.
///
/// Carries the selected animation identifier so that picking another animation
/// in the sidebar of a multi-animation `.lottie` file reloads the player.
private struct DotLottieSelection: Equatable {
    let library: LottieLibrary
    let id: String?
}

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
    @RenderingEngineAppStorage private var renderingEngine

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
                        InfoView(info: LottieAnimationInfo(animation: lottieAnimation, data: animationFile.data))
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
        .task(setUpRenderingEngine)
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
        let viewModel = RiveViewModel(model, artboardName: id)
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
                .resizable()
                .configure { configure(view: $0, configuration: configuration)}
                .playbackMode(playbackMode)
                .animationSpeed(state.configuration.speed)
        case .dotLottie:
            Group {
                if let animation = state.dotLottieAnimation {
                    animation.view()
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .task(id: DotLottieSelection(library: state.configuration.library, id: id), priority: .userInitiated) {
                loadDotLottieAnimation()
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

        let parsingStartTime: Date = .now

        if let animation = state.dotLottieAnimation, let id {
            // The Metal coordinator holds on to the player it was created with,
            // so another animation has to be loaded into the existing instance.
            try? animation.loadAnimationById(id)
        } else if let animation = makeDotLottieAnimation() {
            state.dotLottieAnimation = animation
        } else {
            return
        }

        state.dotLottieParseTime = Date.now.timeIntervalSince(parsingStartTime)
    }

    private func makeDotLottieAnimation() -> DotLottieAnimation? {
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

        if let format = SupportedFileExtension(pathExtension: fileURL.pathExtension), format.isLottieJSON,
           let data = String(data: data, encoding: .utf8) {
            return DotLottieAnimation(animationData: data, config: configuration)
        }

        let animation = DotLottieAnimation(dotLottieData: data, config: configuration)
        if let id {
            try? animation.loadAnimationById(id)
        }
        return animation
    }

    // MARK: - Actions

    /// Seeds this window only. The Library picker still overrides it,
    /// and windows already open are left alone.
    @Sendable
    private nonisolated func setUpRenderingEngine() async {
        await MainActor.run {
            state.configuration.library = renderingEngine
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
