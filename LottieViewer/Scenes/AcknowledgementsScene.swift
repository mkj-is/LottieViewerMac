import SwiftUI

struct AcknowledgementsScene: Scene {
    var body: some Scene {
        Window("Acknowledgements", id: WindowID.acknowledgements.rawValue) {
            AcknowledgementsView()
        }
        .defaultSize(width: 600, height: 400)
        .restorationBehavior(.disabled)
        .defaultPosition(.center)
    }
} 
