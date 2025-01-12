//
//  LottieAnimationInfo.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import Foundation

struct LottieAnimationInfo {
    let startFrame, endFrame: AnimationFrameTime
    let frameRate: Double
    let markerCount: Int

    var version: String?
    var type: Lottie.CoordinateSpace?
    var width, height: Double?
    var layerCount: Int = 0
    var glyphCount: Int = 0

    var byteCount: Int?

    init(animation: LottieAnimation) {
        self.startFrame = animation.startFrame
        self.endFrame = animation.endFrame
        self.frameRate = animation.framerate
        self.markerCount = animation.markerNames.count

        self.byteCount = try? JSONEncoder().encode(animation).count

        // Another possibility was to fork Lottie and make these properties public.
        let mirror = Mirror(reflecting: animation)
        for child in mirror.children {
            switch child.label {
            case "version":
                self.version = child.value as? String
            case "type":
                self.type = child.value as? Lottie.CoordinateSpace
            case "width":
                self.width = child.value as? Double
            case "height":
                self.height = child.value as? Double
            case "layers":
                self.layerCount = (child.value as? [Any])?.count ?? 0
            case "glyphs":
                self.glyphCount = (child.value as? [Any])?.count ?? 0
            default:
                break
            }
        }
    }

    /// For use in previews.
    init(
        startFrame: AnimationFrameTime, endFrame: AnimationFrameTime, frameRate: Double,
        markerCount: Int, version: String?, type: CoordinateSpace?,
        width: Double?, height: Double?, byteCount: Int?
    ) {
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.frameRate = frameRate
        self.markerCount = markerCount
        self.version = version
        self.type = type
        self.width = width
        self.height = height
        self.byteCount = byteCount
    }

    var duration: Measurement<UnitDuration> {
        let duration = (endFrame - startFrame) / frameRate
        return Measurement(value: duration, unit: .seconds)
    }

    var byteMeasurement: Measurement<UnitInformationStorage>? {
        guard let byteCount else {
            return nil
        }
        return Measurement(value: Double(byteCount), unit: UnitInformationStorage.bytes)
    }
}
