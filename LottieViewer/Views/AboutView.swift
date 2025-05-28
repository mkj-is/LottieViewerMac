import SwiftUI
import LottieViewerCore

struct AboutView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)

            Text("Lottie Viewer for Mac")
                .font(.title)

            Text("Made by [Matěj Kašpar Jirásek](https://iosdev.space/@mkj) in Brno, Czechia")
                .font(.subheadline.bold())
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Button("Source on GitHub") {
                openURL(Constant.githubUrl)
            }
            .buttonStyle(.link)

            if let longVersionString {
                Text("Version \(longVersionString)")
                    .font(.subheadline)
            }

            ForEach(LottieLibrary.allCases) { library in
                Text(library.description)
                    .font(.subheadline)
            }
            if let rive = ResolvedPackages.dictionary["rive-ios"] {
                Text("Rive \(rive.version)")
                    .font(.subheadline)
            }

            Button("Acknowledgements") {
                openWindow(id: WindowID.acknowledgements.rawValue)
            }
            .padding(.top)
        }
        .padding()
        .frame(minWidth: 330, minHeight: 250)
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
