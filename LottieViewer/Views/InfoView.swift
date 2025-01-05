//
//  InfoView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 05.01.2025.
//

import SwiftUI

struct InfoView: View {
    let info: Result<LottieAnimationInfo, Error>

    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                Text("Info")
                    .font(.headline)
                    .gridCellColumns(2)
            }
            switch info {
            case .success(let info):
                GridRow {
                    Text("Size:")
                    Text(info.width, format: .number) + Text("×") + Text(info.height, format: .number) + Text(" points")
                }
                GridRow {
                    Text("Frame rate")
                    Text(info.framerate, format: .number) + Text(" fps")
                }
                GridRow {
                    Text("Start frame")
                    Text(info.startFrame, format: .number)
                }
                GridRow {
                    Text("End frame")
                    Text(info.endFrame, format: .number)
                }
            case .failure(let error):
                GridRow {
                    Text("Loading info failed.")
                        .font(.callout)
                }
                GridRow {
                    Text(error.localizedDescription)
                        .font(.footnote)
                }
            }
        }
        .textSelection(.enabled)
    }
}

#Preview {
    InfoView(
        info: .success(
            .init(
                startFrame: 0,
                endFrame: 30,
                framerate: 30,
                version: "v1",
                type: .type2d,
                width: 30,
                height: 30
            )
        )
    )
}
