//
//  PreviewViewController.swift
//  Preview
//
//  Created by Matěj Kašpar Jirásek on 06.01.2025.
//

import Cocoa
import Quartz
import Lottie
import LottieViewerCore

final class PreviewViewController: NSViewController, QLPreviewingController {

    private var animationView: LottieAnimationView!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        let view = LottieAnimationView()
        self.animationView = view
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = view
    }
    
    required init?(coder: NSCoder) {
        let lottieAnimationView = LottieAnimationView()
        self.animationView = lottieAnimationView
        super.init(coder: coder)
        self.view = lottieAnimationView
    }

    func preparePreviewOfFile(at url: URL) async throws {
        if url.pathExtension == LottieFileExtension.dotLottie.rawValue {
            let file = try await DotLottieFile.loadedFrom(url: url)
            animationView.loadAnimation(from: file)
        } else if url.pathExtension == LottieFileExtension.lottie.rawValue {
            animationView.animation = await LottieAnimation.loadedFrom(url: url)
        }
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
}
