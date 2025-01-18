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
            if let longVersionString {
                Text("Version \(longVersionString)")
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
        .textSelection(.enabled)
    }

    private var longVersionString: String? {
        let bundleInfo = Bundle.main.infoDictionary
        guard let shortVersionString = bundleInfo?["CFBundleShortVersionString"] as? String,
            let bundleVersion = bundleInfo?["CFBundleVersion"] as? String
        else {
            return nil
        }
        return "\(shortVersionString) (\(bundleVersion))"


    }
}

#Preview {
    AboutView()
}
