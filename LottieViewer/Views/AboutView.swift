import SwiftUI

struct AboutView: View {
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

            Text("A simple viewer for Lottie animations")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    AboutView()
}
