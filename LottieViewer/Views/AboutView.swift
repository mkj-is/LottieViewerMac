import SwiftUI

struct AboutView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)

            Text("Lottie Viewer for Mac")
                .font(.title)
            if let version = Bundle.main.appVersion {
                Text("Version \(version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Lottie version \(LottieMetadata.version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Acknowledgements") {
                openWindow(id: WindowID.acknowledgements.rawValue)
            }
            .padding(.top)
        }
        .padding()
        .frame(minWidth: 250, minHeight: 200)
    }
}

#Preview {
    AboutView()
}
