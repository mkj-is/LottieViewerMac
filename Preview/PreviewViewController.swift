//
//  PreviewViewController.swift
//  Preview
//
//  Created by Matěj Kašpar Jirásek on 06.01.2025.
//

import Cocoa
import Quartz
import Lottie

enum LottiePreviewError: Error {
    /// DotLottie file does not contain any animation.
    case noAnimations
}

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

    /*
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?) async throws {
        // Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.

        // Perform any setup necessary in order to prepare the view.
        // Quick Look will display a loading spinner until this returns.
    }
    */

    func preparePreviewOfFile(at url: URL) async throws {
        if url.pathExtension == "lottie" {
            let animations = try await DotLottieFile.loadedFrom(url: url).animations
            guard let firstAnimation = animations.first else {
                throw LottiePreviewError.noAnimations
            }
            animationView.animation = firstAnimation.animation
        } else if url.pathExtension == "json" {
            animationView.animation = await LottieAnimation.loadedFrom(url: url)
        }
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
}
