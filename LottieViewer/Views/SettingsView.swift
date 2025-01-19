import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.showInfoByDefault.rawValue) private var showInfoByDefault = true
    
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
