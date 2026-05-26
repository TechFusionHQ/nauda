import SwiftUI

@main
struct NaudaApp: App {
    // Adapter to instantiate AppKit AppDelegate for menu bar status item and popover management.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Returning a Settings scene prevents macOS from opening any default app window on launch,
        // leaving the app to run completely and cleanly in the menu bar.
        Settings {
            EmptyView()
        }
    }
}
