import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        ScrollView {
            ForEach(sortedPackages, id: \.key) { element in
                Link(element.key, destination: element.value.location)
                    .underline()
                    .foregroundColor(.accent)
                    .font(.largeTitle)
                    .padding()
                Text(element.value.license)
                    .font(.system(.body, design: .monospaced))
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 700)
        .textSelection(.enabled)
    }

    private var sortedPackages: [(key: String, value: Package)] {
        Array(ResolvedPackages.dictionary)
            .sorted { left, right in
                left.key.localizedCaseInsensitiveCompare(right.key) == .orderedAscending
            }
    }
}

#Preview {
    AcknowledgementsView()
} 
