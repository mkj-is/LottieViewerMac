//
//  DocumentView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 03.01.2025.
//

import SwiftUI
import Lottie

struct DocumentView: View {
    @Binding var document: AnimationFileDocument

    @State private var selection: String?

    var body: some View {
        switch identifiers.count {
        case 2...:
            NavigationSplitView {
                List(identifiers, id: \.self, selection: $selection) { identifier in
                    Text(identifier)
                }
            } detail: {
                AnimationView(animationFile: document.animationFile, id: selection)
                    .environment(\.parseTime, document.parseTime)
            }
        case 1:
            AnimationView(animationFile: document.animationFile, id: selection)
                .environment(\.parseTime, document.parseTime)
        default:
            Text("No animations included in this file.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var identifiers: [String] {
        document.animationFile.identifiers
    }
}
