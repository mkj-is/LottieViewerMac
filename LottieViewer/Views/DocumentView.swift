//
//  DocumentView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import Lottie

struct DocumentViewState {
    var animation: LottieAnimation?
    var selection: String?
}

struct DocumentView: View {
    @Binding var document: LottieFileDocument

    @State private var state = DocumentViewState()

    var body: some View {
        if let firstAnimation = document.animations.first {
            if document.animations.count > 1 {
                NavigationSplitView {
                    List(identifiers, id: \.self, selection: $state.selection) { identifier in
                        Text(identifier)
                    }
                } detail: {
                    AnimationView(animation: selectedAnimation ?? firstAnimation, id: state.selection)
                }
            } else {
                AnimationView(animation: firstAnimation, id: state.selection)
            }
        } else {
            Text("No animations included in this file.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var identifiers: [String] {
        document.animations.compactMap(\.configuration).map(\.id)
    }

    private var selectedAnimation: LottieFileDocument.Animation? {
        document.animations.first(where: { animation in
            animation.configuration?.id == state.selection
        })
    }
}
