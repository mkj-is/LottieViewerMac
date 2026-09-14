//
//  PreviewViewController.swift
//  Preview
//
//  Created by Matěj Kašpar Jirásek on 06.01.2025.
//

import Cocoa
import DotLottie
import Lottie
import LottieViewerCore
import Quartz
import SwiftUI

final class PreviewViewController: NSViewController, QLPreviewingController {

    /// Retained for the lifetime of the preview, the rendering is driven by the player inside.
    private var dotLottieAnimation: DotLottieAnimation?

    override func loadView() {
        view = NSView()
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let animationView: NSView

        switch UserDefaults.shared.renderingEngine {
        case .lottie:
            animationView = try await makeLottieView(url: url)
        case .dotLottie:
            animationView = try makeDotLottieView(url: url)
        }

        animationView.frame = view.bounds
        animationView.autoresizingMask = [.width, .height]
        view.addSubview(animationView)
    }

    private func makeLottieView(url: URL) async throws -> NSView {
        let animationView = LottieAnimationView()
        switch SupportedFileExtension(pathExtension: url.pathExtension) {
        case .dotLottie:
            let file = try await DotLottieFile.loadedFrom(url: url)
            animationView.loadAnimation(from: file)
        case .lottie, .lot:
            animationView.animation = await LottieAnimation.loadedFrom(url: url)
        case .rive, nil:
            break
        }
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }

    private func makeDotLottieView(url: URL) throws -> NSView {
        let data = try Data(contentsOf: url)
        let animation = DotLottieAnimation(
            lottieData: data,
            config: AnimationConfig(autoplay: true, loop: true)
        )
        dotLottieAnimation = animation
        return NSHostingView(rootView: animation.view())
    }
}
