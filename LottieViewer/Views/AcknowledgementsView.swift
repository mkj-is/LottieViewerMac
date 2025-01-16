import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        ScrollView {
            Text("Lottie")
                .font(.largeTitle)
                .padding()
            Text(LottieMetadata.license)
                .font(.system(.body, design: .monospaced))
                .padding(.bottom)
                .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 700)
        .textSelection(.enabled)
    }
}

#Preview {
    AcknowledgementsView()
} 
