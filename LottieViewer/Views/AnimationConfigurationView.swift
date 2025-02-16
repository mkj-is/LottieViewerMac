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
    var backgroundColor: Color = Color(nsColor: NSColor.windowBackgroundColor)
    var library: LottieLibrary = .lottie

    var speed: Double {
        pow(2.0, speedExponent)
    }
}

struct AnimationConfigurationView: View {
    @Binding var state: AnimationConfigurationViewState

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading) {
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

            ColorPicker("Background color", selection: $state.backgroundColor)

            HStack {
                Picker("Library", selection: $state.library) {
                    ForEach(LottieLibrary.allCases) { library in
                        Text(library.description).tag(library)
                    }
                }
                Button(action: openLibraryURL) {
                    Image(systemName: "arrowshape.forward.circle")
                        .foregroundStyle(Color.accentColor)
                }
                .help("Open repository in browser")
                .buttonStyle(.plain)
            }
        }
    }

    private func openLibraryURL() {
        guard let package = state.library.package else {
            return
        }
        openURL(package.location)
    }
}

#Preview {
    AnimationConfigurationView(state: .constant(AnimationConfigurationViewState()))
        .frame(maxWidth: 300)
        .padding()
}
