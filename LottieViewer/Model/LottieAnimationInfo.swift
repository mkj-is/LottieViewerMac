//
//  LottieAnimationInfo.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import Foundation

struct LottieAnimationInfo: Decodable {
    let startFrame: AnimationFrameTime
    let endFrame: AnimationFrameTime
    let frameRate: Double
    let version: String
    let type: Lottie.CoordinateSpace?
    let width: Int
    let height: Int
    var byteCount: Int?

    private enum CodingKeys: String, CodingKey {
      case version = "v"
      case type = "ddd"
      case startFrame = "ip"
      case endFrame = "op"
      case frameRate = "fr"
      case width = "w"
      case height = "h"
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
