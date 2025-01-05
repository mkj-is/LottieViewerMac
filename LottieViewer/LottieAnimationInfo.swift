//
//  LottieAnimationInfo.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie

struct LottieAnimationInfo: Decodable {
    let startFrame: AnimationFrameTime
    let endFrame: AnimationFrameTime
    let framerate: Double
    let version: String
    let type: Lottie.CoordinateSpace?
    let width: Double
    let height: Double
    var byteCount: Int?

    enum CodingKeys: String, CodingKey {
      case version = "v"
      case type = "ddd"
      case startFrame = "ip"
      case endFrame = "op"
      case framerate = "fr"
      case width = "w"
      case height = "h"
    }
}
