//
//  ThumbnailProvider.swift
//  Thumbnail
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

import QuickLookThumbnailing
import Lottie
import LottieViewerCore
import OSLog

final class ThumbnailProvider: QLThumbnailProvider {

    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        Task.detached {
            do {
                let animation = try await self.loadAnimation(url: request.fileURL)
                let reply = QLThumbnailReply(contextSize: request.maximumSize) { context in
                    let view = self.makeAnimationView(animation: animation, size: request.maximumSize)
                    view.layer?.render(in: context)
                    return true
                }
                handler(reply, nil)
            } catch {
                handler(nil, error)
            }
        }
    }

    private func makeAnimationView(animation: LottieAnimation, size: CGSize) -> LottieAnimationView {
        let animationView = LottieAnimationView(animation: animation)
        animationView.frame = CGRect(origin: .zero, size: size)
        animationView.contentMode = .scaleAspectFit
        animationView.currentFrame = 0
        return animationView
    }

    private func loadAnimation(url: URL) async throws -> LottieAnimation {
        if url.pathExtension == SupportedFileExtension.dotLottie.rawValue {
            let animations = try await DotLottieFile.loadedFrom(url: url).animations
            guard let firstAnimation = animations.first else {
                throw LottiePreviewError.noAnimations
            }
            return firstAnimation.animation
        } else if url.pathExtension == SupportedFileExtension.lottie.rawValue {
            let animation = await LottieAnimation.loadedFrom(url: url)
            guard let animation else {
                throw LottiePreviewError.noAnimations
            }
            return animation
        }
        throw LottiePreviewError.unknownFileFormat
    }
}
