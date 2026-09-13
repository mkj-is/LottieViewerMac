import LottieViewerCore
import SwiftUI

struct SettingsView: View {
    @ShowInfoAppStorage private var showInfoByDefault
    @RenderingEngineAppStorage private var renderingEngine

    var body: some View {
        Form {
            Toggle("Show Info Panel by default", isOn: $showInfoByDefault)

            Picker("Rendering engine", selection: $renderingEngine) {
                ForEach(LottieLibrary.allCases) { library in
                    Text(library.description).tag(library)
                }
            }
            Text("Used for QuickLook previews and thumbnails, and as the default for newly opened windows.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
