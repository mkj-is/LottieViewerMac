//
//  InfoView.swift
//  LottieViewer
//
//  Created by Matěj Kašpar Jirásek on 05.01.2025.
//

import SwiftUI

struct InfoView: View {
    let info: LottieAnimationInfo

    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                Text("Info")
                    .font(.title)
                    .gridCellColumns(2)
            }
            if let width = info.width, let height = info.height {
                let width = Int(width)
                let height = Int(height)
                GridRow {
                    Text("Resolution:")
                        .font(.headline)

                    let wideLabel = Text("\(width)×\(height) points", comment: "Wide unit – Points")
                    ViewThatFits(in: .horizontal) {
                        wideLabel
                        Text("\(width)×\(height) pts", comment: "Abbreviated unit – Points")
                        Text("\(width)×\(height) p", comment: "Narrow unit – Points")
                    }
                    .accessibilityLabel(wideLabel)
                }
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
            GridRow {
                ViewThatFits(in: .horizontal) {
                    Text("Root layer count:")
                    Text("Layer count:")
                    Text("Layers:")
                }
                .font(.headline)

                Text(info.layerCount, format: .number)
            }
            GridRow {
                ViewThatFits(in: .horizontal) {
                    Text("Glyph count:")
                    Text("Glyphs:")
                }
                .font(.headline)

                Text(info.layerCount, format: .number)
            }
            if let byteMeasurement = info.byteMeasurement {
                GridRow {
                    Text("Size:")
                        .font(.headline)
                    Text(byteMeasurement, format: .byteCount(style: .file))
                }
            }
            if let version = info.version {
                GridRow {
                    ViewThatFits(in: .horizontal) {
                        Text("File version:")
                        Text("Version:")
                    }
                    .font(.headline)

                    Text(version)
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
        info: LottieAnimationInfo(startFrame: 0, endFrame: 100, frameRate: 30, markerCount: 10, version: "1.0.0", type: .type2d, width: 100, height: 100, byteCount: 30 * 1000)
    )
}
