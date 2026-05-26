import SwiftUI
import AppKit

// A wrapper for NSVisualEffectView to provide a modern glassmorphic background in macOS popovers.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .popover
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

// Procedural steam line drawing a smooth wave that rises and fades
struct SteamLine: View {
    @State private var progress: CGFloat = 0
    let delay: Double
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 5, y: 30))
            path.addCurve(
                to: CGPoint(x: 5, y: 0),
                control1: CGPoint(x: -3, y: 20),
                control2: CGPoint(x: 13, y: 10)
            )
        }
        .stroke(
            LinearGradient(
                colors: [Color.orange.opacity(0.6), Color.primary.opacity(0.02)],
                startPoint: .bottom,
                endPoint: .top
            ),
            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
        )
        .frame(width: 10, height: 30)
        .offset(y: -progress * 25)
        .opacity(progress < 0.2 ? Double(progress / 0.2) : (progress > 0.8 ? Double((1.0 - progress) / 0.2) : 1.0))
        .onAppear {
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
            ) {
                progress = 1.0
            }
        }
    }
}

struct SteamView: View {
    let active: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            SteamLine(delay: 0.0)
            SteamLine(delay: 0.6)
            SteamLine(delay: 1.2)
        }
        .frame(height: 30)
        .opacity(active ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: active)
    }
}

struct CoffeeCupButton: View {
    let active: Bool
    let action: () -> Void
    @State private var isHovering = false
    @State private var isPulseActive = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow effect behind the cup when active
                Circle()
                    .fill(Color.orange.opacity(active ? 0.15 : 0.0))
                    .frame(width: 110, height: 110)
                    .blur(radius: 15)
                    .scaleEffect(active && isPulseActive ? 1.15 : 1.0)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                        ) {
                            isPulseActive = true
                        }
                    }
                
                // Custom vector Vietnamese coffee glass drawing
                VietnameseCoffeeIcon(isActive: active)
                    .frame(width: 76, height: 76)
                    .opacity(active ? 1.0 : 0.6) // Subtle dimming when inactive
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .shadow(color: active ? Color.orange.opacity(0.35) : Color.clear, radius: isHovering ? 12 : 6)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovering = hovering
            }
        }
    }
}

struct QuitButton: View {
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "power")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isHovering ? .red : .secondary.opacity(0.8))
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovering ? Color.red.opacity(0.12) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .help("Quit Nauda")
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState
    
    // Bindings to translate start/end time DatePicker state into persisted integer hours/minutes
    private var startTimeBinding: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = state.startHour
                components.minute = state.startMinute
                return calendar.date(from: components) ?? Date()
            },
            set: { newDate in
                let calendar = Calendar.current
                state.startHour = calendar.component(.hour, from: newDate)
                state.startMinute = calendar.component(.minute, from: newDate)
            }
        )
    }
    
    private var endTimeBinding: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = state.endHour
                components.minute = state.endMinute
                return calendar.date(from: components) ?? Date()
            },
            set: { newDate in
                let calendar = Calendar.current
                state.endHour = calendar.component(.hour, from: newDate)
                state.endMinute = calendar.component(.minute, from: newDate)
            }
        )
    }
    
    var body: some View {
        ZStack {
            // Underlay glassmorphic blur background
            VisualEffectView(material: .popover, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    // Vector Vietnamese coffee icon next to App name
                    VietnameseCoffeeIcon(isActive: true)
                        .frame(width: 22, height: 22)
                    Text("Nauda")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Coffee Cup + Steam Section
                VStack(spacing: 4) {
                    SteamView(active: state.isActive)
                        .frame(height: 30)
                    
                    CoffeeCupButton(active: state.isActive) {
                        state.togglePause()
                    }
                    .padding(.vertical, 8)
                    
                    // Status Banners
                    Text(statusTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(state.isActive ? .orange : .secondary)
                    
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 32)
                        .padding(.horizontal, 16)
                }
                
                // Settings Section (Card View)
                VStack(spacing: 12) {
                    // Schedule Toggle
                    Toggle(isOn: $state.isScheduleEnabled) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Schedule Keep Awake")
                                .fontWeight(.medium)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                    
                    if state.isScheduleEnabled {
                        Divider()
                            .opacity(0.5)
                        
                        // Time Range Selector
                        HStack {
                            Text("Active Hours")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            DatePicker("", selection: startTimeBinding, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                            Text("to")
                                .foregroundColor(.secondary)
                            DatePicker("", selection: endTimeBinding, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        
                        Divider()
                            .opacity(0.5)
                        
                        // Interval Picker
                        HStack {
                            Text("Repeat")
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("", selection: $state.scheduleInterval) {
                                Text("Everyday").tag("everyday")
                                Text("Weekdays").tag("weekdays")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 150)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Footer / Actions
                HStack(alignment: .center) {
                    Text("v0.0.1")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                    Spacer()
                    QuitButton(action: quitApp)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 320, height: 420)
    }
    
    // Dynamic text based on current operation state
    private var statusTitle: String {
        if state.isActive {
            return "Vietnamese coffee is the best 🇻🇳"
        } else if state.isPaused {
            return "Paused"
        } else {
            return "Waiting for your coffee"
        }
    }
    
    private var statusDescription: String {
        if state.isActive {
            if state.isScheduleEnabled {
                let endString = formatTime(hour: state.endHour, minute: state.endMinute)
                return "Your Mac is staying awake until \(endString) per schedule."
            } else {
                return "Your Mac is staying awake indefinitely."
            }
        } else {
            if state.isPaused {
                return "Click the coffee cup to resume keeping your Mac awake."
            } else if state.isScheduleEnabled && !state.isTimeWithinSchedule() {
                let startString = formatTime(hour: state.startHour, minute: state.startMinute)
                let days = state.scheduleInterval == "weekdays" ? "weekdays" : "everyday"
                return "Scheduled to resume at \(startString) (\(days))."
            } else {
                return "Idle."
            }
        }
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return String(format: "%02d:%02d", hour, minute)
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
