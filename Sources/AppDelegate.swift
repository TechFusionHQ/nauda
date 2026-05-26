import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let appState = AppState()
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the system status bar item with variable width
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Configure status bar button action and target
            button.action = #selector(togglePopover(_:))
            button.target = self
            
            // Set initial icon
            updateStatusItemIcon(isActive: appState.isActive)
        }
        
        // Pass AppState down to the SwiftUI ContentView
        let contentView = ContentView(state: appState)
        
        // Set up the custom popover controller
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 420)
        popover.behavior = .transient // Automatically hides when user clicks outside
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Observe AppState's isActive publisher to change the menu bar icon dynamically
        appState.$isActive
            .receive(on: RunLoop.main)
            .sink { [weak self] isActive in
                self?.updateStatusItemIcon(isActive: isActive)
            }
            .store(in: &cancellables)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Keep app state active and run scheduling check before opening UI
                appState.updateAssertion()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                
                // Bring application to the front to handle input focus and keyboard shortcuts correctly
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func updateStatusItemIcon(isActive: Bool) {
        guard let button = statusItem?.button else { return }
        
        // Render custom vector Vietnamese coffee glass directly into menu bar status button
        let iconView = VietnameseCoffeeIcon(isActive: isActive)
        if let image = iconView.toNSImage(size: NSSize(width: 18, height: 18)) {
            button.image = image
        }
    }
}
