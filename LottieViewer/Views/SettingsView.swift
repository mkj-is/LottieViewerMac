import SwiftUI

struct SettingsView: View {
    @ShowInfoAppStorage private var showInfoByDefault

    var body: some View {
        Form {
            Toggle("Show Info Panel by default", isOn: $showInfoByDefault)
                .padding()
        }
    }
}

#Preview {
    SettingsView()
} 
