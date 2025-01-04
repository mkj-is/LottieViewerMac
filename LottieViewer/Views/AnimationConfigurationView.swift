//
//  AnimationConfigurationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import SwiftUI
import Lottie

struct AnimationConfigurationViewState {
    var loopMode: LottieLoopMode = .loop
    /// Indicates step in slider, exponent of 2. Not actual speed.
    var speedExponent = 0.0

    var speed: Double {
        pow(2.0, speedExponent)
    }
}

struct AnimationConfigurationView: View {
    @Binding var state: AnimationConfigurationViewState

    var body: some View {
        VStack {
            Picker(selection: $state.loopMode, label: Text("Loop mode")) {
                Text("Loop").tag(LottieLoopMode.loop)
                Text("Auto reverse").tag(LottieLoopMode.autoReverse)
                Text("Play once").tag(LottieLoopMode.playOnce)
            }

            Slider(value: $state.speedExponent, in: -2.0...3.0, step: 1.0) {
                Text("Playback speed")
            }
            minimumValueLabel: { Text("¼×") }
            maximumValueLabel: { Text("8×") }
        }
        .padding()
        .frame(minWidth: 200, maxWidth: 350, maxHeight: .infinity)
    }
}

#Preview {
    AnimationConfigurationView(state: .constant(AnimationConfigurationViewState()))
}
