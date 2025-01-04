//
//  ContentView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import Lottie

struct ContentView: View {
    @Binding var document: LottieViewerDocument

    var body: some View {
        LottieView(animation: document.animation)
            .playing(loopMode: .loop)
    }
}
