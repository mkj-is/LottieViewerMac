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
                    .font(.title)
                    .gridCellColumns(2)
            }
            switch info {
            case .success(let info):
                GridRow {
                    Text("Resolution:")
                        .font(.headline)
                    Text(info.width, format: .number) + Text("×") + Text(info.height, format: .number) + Text(" points")
                }
                GridRow {
                    Text("Frame rate:")
                        .font(.headline)
                    Text(info.frameRate, format: .number) + Text(" fps")
                }
                GridRow {
                    Text("Duration:")
                        .font(.headline)
                    Text(info.duration, format: .measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(2))))
                }
                GridRow {
                    Text("Start frame:")
                        .font(.headline)
                    Text(info.startFrame, format: .number)
                }
                GridRow {
                    Text("End frame:")
                        .font(.headline)
                    Text(info.endFrame, format: .number)
                }
                if let byteCount = info.byteCount {
                    GridRow {
                        Text("Size:")
                            .font(.headline)
                        Text(Measurement(value: Double(byteCount), unit: UnitInformationStorage.bytes), format: .byteCount(style: .file))
                    }
                }
                GridRow {
                    Text("Version:")
                        .font(.headline)
                    Text(info.version)
                }
            case .failure(let error):
                GridRow {
                    Text("Loading info failed.")
                        .font(.headline)
                        .gridCellColumns(2)
                }
                GridRow {
                    Text(error.localizedDescription)
                        .gridCellColumns(2)
                }
            }
        }
        .textSelection(.enabled)
    }
}

#Preview("Info") {
    InfoView(
        info: .success(
            .init(
                startFrame: 0,
                endFrame: 30,
                frameRate: 30,
                version: "v1",
                type: .type2d,
                width: 30,
                height: 30,
                byteCount: 30 * 1024
            )
        )
    )
}

#Preview("Info error") {
    InfoView(
        info: .failure(NSError(domain: "Preview", code: 0))
    )
}
