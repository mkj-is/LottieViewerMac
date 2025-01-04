//
//  AnimationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import Lottie
import SwiftUI

struct AnimationView: View {
    let animation: LottieAnimation

    var body: some View {
        LottieView(animation: animation)
            .playing(loopMode: .loop)
    }
}
