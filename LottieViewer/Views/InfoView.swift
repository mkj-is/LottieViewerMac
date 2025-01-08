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

                    let wideLabel = Text("\(info.width)×\(info.height) points", comment: "Wide unit – Points")
                    ViewThatFits(in: .horizontal) {
                        wideLabel
                        Text("\(info.width)×\(info.height) pts", comment: "Abbreviated unit – Points")
                        Text("\(info.width)×\(info.height) p", comment: "Narrow unit – Points")
                    }
                    .accessibilityLabel(wideLabel)
                }
                GridRow {
                    Text("Frame rate:")
                        .font(.headline)
                    measurementThatFits(unit: UnitFrequency.self) { width in
                        Text(Measurement(value: info.frameRate, unit: UnitFrequency.framesPerSecond), format: .measurement(width: width))
                    }
                }
                GridRow {
                    Text("Duration:")
                        .font(.headline)
                    measurementThatFits(unit: UnitDuration.self) { width in
                        Text(info.duration, format: .measurement(width: width, numberFormatStyle: .number.precision(.fractionLength(2))))
                    }
                }
                GridRow {
                    ViewThatFits(in: .horizontal) {
                        Text("Start frame:")
                        Text("Start:")
                    }
                    .font(.headline)

                    Text(info.startFrame, format: .number)
                }
                GridRow {
                    ViewThatFits(in: .horizontal) {
                        Text("End frame:")
                        Text("End:")
                    }
                    .font(.headline)

                    Text(info.endFrame, format: .number)
                }
                if let byteMeasurement = info.byteMeasurement {
                    GridRow {
                        Text("Size:")
                            .font(.headline)
                        Text(byteMeasurement, format: .byteCount(style: .file))
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

    private func measurementThatFits<U>(unit: U.Type = U.self, text: (Measurement<U>.FormatStyle.UnitWidth) -> Text) -> some View {
        ViewThatFits(in: .horizontal) {
            text(.wide)
            text(.abbreviated)
            text(.narrow)
        }
        .accessibilityLabel(text(.wide))
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
