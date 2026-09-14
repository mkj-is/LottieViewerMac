//
//  ThumbnailProvider.swift
//  Thumbnail
//
//  Created by Matěj Kašpar Jirásek on 07.01.2025.
//

import AppKit
import DotLottie
import Lottie
import LottieViewerCore
import QuickLookThumbnailing

final class ThumbnailProvider: QLThumbnailProvider {

    /// A rendered frame plus the size QuickLook should use for the thumbnail.
    private struct Thumbnail {
        let image: CGImage
        /// Aspect-fitted size in points. Passing `request.maximumSize` here is what
        /// made thumbnails look padded and mis-sized, since it is only a bounding box.
        let size: CGSize

        var reply: QLThumbnailReply {
            let image = image
            // `contextSize` is in points, but the context QuickLook hands back is
            // backed at the request's scale and its units are pixels. Drawing
            // into a point-sized rect put the image in a corner of the bitmap at
            // 2x, so the rect is the image's own pixel extent.
            let pixelSize = CGSize(width: image.width, height: image.height)
            return QLThumbnailReply(contextSize: size) { context in
                context.draw(image, in: CGRect(origin: .zero, size: pixelSize))
                return true
            }
        }
    }

    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        // QuickLook hands these over for the duration of the call, the provider
        // holds no state, and the rendering below is confined to the main
        // actor, so the hop is safe.
        nonisolated(unsafe) let provider = self
        nonisolated(unsafe) let request = request
        nonisolated(unsafe) let handler = handler
        Task { @MainActor in
            do {
                let thumbnail: Thumbnail
                switch UserDefaults.shared.renderingEngine {
                case .lottie:
                    thumbnail = try await provider.lottieThumbnail(for: request)
                case .dotLottie:
                    thumbnail = try provider.dotLottieThumbnail(for: request)
                }
                handler(thumbnail.reply, nil)
            } catch {
                handler(nil, error)
            }
        }
    }

    /// Largest size with the animation's aspect ratio that fits the requested bounding box.
    private func thumbnailSize(for intrinsicSize: CGSize, in maximumSize: CGSize) -> CGSize {
        guard intrinsicSize.width > 0, intrinsicSize.height > 0 else {
            // `intrinsicContentSize` is `.zero` when no animation is loaded.
            return maximumSize
        }
        let scale = min(
            maximumSize.width / intrinsicSize.width,
            maximumSize.height / intrinsicSize.height
        )
        return CGSize(
            width: max(1, (intrinsicSize.width * scale).rounded()),
            height: max(1, (intrinsicSize.height * scale).rounded())
        )
    }

    // MARK: - Lottie

    @MainActor
    private func lottieThumbnail(for request: QLFileThumbnailRequest) async throws -> Thumbnail {
        let animation = try await loadAnimation(url: request.fileURL)

        let animationView = LottieAnimationView(
            animation: animation,
            configuration: LottieConfiguration(renderingEngine: .mainThread)
        )

        // `LottieAnimation`'s own width/height are not public, and the animation
        // view is the only public way to read them.
        let naturalSize = animationView.intrinsicContentSize
        guard naturalSize.width > 0, naturalSize.height > 0 else {
            throw LottiePreviewError.notDecoded
        }
        let size = thumbnailSize(for: naturalSize, in: request.maximumSize)
        let bounds = CGRect(origin: .zero, size: size)

        // Lottie only positions and scales its content from `layoutAnimation()`,
        // which AppKit drives from `layout()` and the view moving to a window.
        // Off-screen views never get either, so the animation rendered at a
        // fraction of the requested size. An off-screen window provides both.
        let window = NSWindow(
            contentRect: bounds,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        defer { window.contentView = nil }

        animationView.frame = bounds
        animationView.contentMode = .scaleAspectFit
        window.contentView = animationView
        animationView.currentFrame = animation.startFrame
        animationView.needsLayout = true
        animationView.layoutSubtreeIfNeeded()
        animationView.needsDisplay = true
        animationView.displayIfNeeded()

        // The view is laid out in points and the context scales those to pixels.
        // The scale must be applied to the context rather than left to AppKit:
        // an off-screen window in an extension does not rasterize at the
        // requested scale, which drew the animation into a quarter of the
        // thumbnail. Rendering the layer honours the context transform.
        guard let context = CGContext(
            data: nil,
            width: Int((size.width * request.scale).rounded()),
            height: Int((size.height * request.scale).rounded()),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw LottiePreviewError.notDecoded
        }

        context.scaleBy(x: request.scale, y: request.scale)
        // `CALayer` draws top-down, the bitmap context bottom-up.
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        animationView.layer?.render(in: context)

        guard let image = context.makeImage() else {
            throw LottiePreviewError.notDecoded
        }
        return Thumbnail(image: image, size: size)
    }

    @MainActor
    private func loadAnimation(url: URL) async throws -> LottieAnimation {
        switch SupportedFileExtension(pathExtension: url.pathExtension) {
        case .dotLottie:
            let animations = try await DotLottieFile.loadedFrom(url: url).animations
            guard let firstAnimation = animations.first else {
                throw LottiePreviewError.noAnimations
            }
            return firstAnimation.animation
        case .lottie, .lot:
            guard let animation = await LottieAnimation.loadedFrom(url: url) else {
                throw LottiePreviewError.notDecoded
            }
            return animation
        case .rive, nil:
            throw LottiePreviewError.unknownFileFormat
        }
    }

    // MARK: - DotLottie

    /// Renders a single frame using the software rasterizer.
    ///
    /// Uses the low-level player rather than `DotLottieAnimation`, whose data
    /// initializers load asynchronously on the main actor. QuickLook wants one
    /// synchronous frame, and these loaders return a result immediately.
    private func dotLottieThumbnail(for request: QLFileThumbnailRequest) throws -> Thumbnail {
        let url = request.fileURL
        let data = try Data(contentsOf: url)
        let player = DotLottiePlayer(config: Config(autoplay: false))

        // The renderer has to be configured before the animation is loaded, the
        // way the library does it internally. Sized to the whole requested box
        // because the animation's own size is only known after loading.
        let width = Int((request.maximumSize.width * request.scale).rounded())
        let height = Int((request.maximumSize.height * request.scale).rounded())
        let bytesPerRow = width * 4

        let buffer = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        buffer.initialize(repeating: 0, count: width * height)
        defer {
            buffer.deinitialize(count: width * height)
            buffer.deallocate()
        }

        guard player.setSoftwareTarget(
            buffer: buffer,
            width: UInt32(width),
            height: UInt32(height),
            colorSpace: .abgr8888
        ) else {
            throw LottiePreviewError.notDecoded
        }

        let loaded: Bool
        switch SupportedFileExtension(pathExtension: url.pathExtension) {
        case .dotLottie:
            loaded = player.loadDotlottieData(fileData: data)
        case .lottie, .lot:
            guard let json = String(data: data, encoding: .utf8) else {
                throw LottiePreviewError.notDecoded
            }
            loaded = player.loadAnimationData(animationData: json)
        case .rive, nil:
            throw LottiePreviewError.unknownFileFormat
        }
        guard loaded else {
            throw LottiePreviewError.notDecoded
        }

        // `setFrame` reports false when the frame is already current, and
        // `render` alone then rasterizes nothing. `tick` is what the library
        // itself uses to produce a still frame.
        _ = player.tick(dt: 0)
        _ = player.render()

        let pixels = Data(bytes: buffer, count: bytesPerRow * height)
        guard
            let provider = CGDataProvider(data: pixels as CFData),
            let full = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            )
        else {
            throw LottiePreviewError.notDecoded
        }

        // The core letterboxes the animation into the buffer using the default
        // `.contain` layout, so crop back to the animation's own aspect ratio.
        let size = thumbnailSize(for: player.animationSize(), in: request.maximumSize)
        let cropWidth = Int((size.width * request.scale).rounded())
        let cropHeight = Int((size.height * request.scale).rounded())
        let cropRect = CGRect(
            x: (width - cropWidth) / 2,
            y: (height - cropHeight) / 2,
            width: cropWidth,
            height: cropHeight
        )
        guard let image = full.cropping(to: cropRect) else {
            throw LottiePreviewError.notDecoded
        }

        return Thumbnail(image: image, size: size)
    }
}
