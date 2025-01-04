//
//  AnimationConfigurationView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 04.01.2025.
//

import SwiftUI

struct AnimationConfigurationViewState {
    var speed = 1.0
}

struct AnimationConfigurationView: View {
    @Binding var state: AnimationConfigurationViewState

    var body: some View {
        VStack {
            Slider(value: $state.speed, in: 0.25...4, step: 0.25) {
                Text("Animation speed")
            }
        }
        .padding()
        .frame(minWidth: 200, maxWidth: 350, maxHeight: .infinity)
    }
}

#Preview {
    AnimationConfigurationView(state: .constant(AnimationConfigurationViewState(speed: 1)))
}
