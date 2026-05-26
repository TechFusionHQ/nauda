import Foundation
import AppKit
import IOKit.pwr_mgt
import Combine

class AppState: ObservableObject {
    @Published var isActive: Bool = false
    
    // UserDefaults persisted settings
    @Published var isPaused: Bool {
        didSet {
            UserDefaults.standard.set(isPaused, forKey: "isPaused")
            updateAssertion()
        }
    }
    @Published var isScheduleEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isScheduleEnabled, forKey: "isScheduleEnabled")
            updateAssertion()
        }
    }
    @Published var scheduleInterval: String {
        didSet {
            UserDefaults.standard.set(scheduleInterval, forKey: "scheduleInterval")
            updateAssertion()
        }
    }
    
    // Start Time (Hour/Minute)
    @Published var startHour: Int {
        didSet {
            UserDefaults.standard.set(startHour, forKey: "startHour")
            updateAssertion()
        }
    }
    @Published var startMinute: Int {
        didSet {
            UserDefaults.standard.set(startMinute, forKey: "startMinute")
            updateAssertion()
        }
    }
    
    // End Time (Hour/Minute)
    @Published var endHour: Int {
        didSet {
            UserDefaults.standard.set(endHour, forKey: "endHour")
            updateAssertion()
        }
    }
    @Published var endMinute: Int {
        didSet {
            UserDefaults.standard.set(endMinute, forKey: "endMinute")
            updateAssertion()
        }
    }
    
    private var assertionID: IOPMAssertionID = 0
    private var isSystemSleeping: Bool = false
    private var timer: Timer?
    
    init() {
        // Load settings from UserDefaults (defaults: not paused, schedule disabled, 9 AM - 5 PM everyday)
        self.isPaused = UserDefaults.standard.object(forKey: "isPaused") as? Bool ?? false
        self.isScheduleEnabled = UserDefaults.standard.object(forKey: "isScheduleEnabled") as? Bool ?? false
        self.scheduleInterval = UserDefaults.standard.string(forKey: "scheduleInterval") ?? "everyday"
        self.startHour = UserDefaults.standard.object(forKey: "startHour") as? Int ?? 9
        self.startMinute = UserDefaults.standard.object(forKey: "startMinute") as? Int ?? 0
        self.endHour = UserDefaults.standard.object(forKey: "endHour") as? Int ?? 17
        self.endMinute = UserDefaults.standard.object(forKey: "endMinute") as? Int ?? 0
        
        setupNotifications()
        setupTimer()
        updateAssertion()
    }
    
    deinit {
        timer?.invalidate()
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
        }
    }
    
    private func setupNotifications() {
        let center = NSWorkspace.shared.notificationCenter
        
        // Listen for system going to sleep
        center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            print("Nauda: System is going to sleep. Releasing assertion.")
            self?.isSystemSleeping = true
            self?.updateAssertion()
        }
        
        // Listen for system waking up
        center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            print("Nauda: System woke up. Re-evaluating assertion.")
            self?.isSystemSleeping = false
            self?.updateAssertion()
        }
    }
    
    private func setupTimer() {
        // Timer checks schedule every 15 seconds to handle minute transitions seamlessly
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.updateAssertion()
        }
    }
    
    func togglePause() {
        isPaused.toggle()
    }
    
    func updateAssertion() {
        var shouldKeepAwake = false
        
        // Only keep awake if not paused and the system is not actively sleeping
        if !isPaused && !isSystemSleeping {
            if isScheduleEnabled {
                shouldKeepAwake = isTimeWithinSchedule()
            } else {
                shouldKeepAwake = true
            }
        }
        
        if shouldKeepAwake {
            if assertionID == 0 {
                let reason = "Nauda Keep Awake Active" as CFString
                // Prevent display and system idle sleep
                let success = IOPMAssertionCreateWithDescription(
                    kIOPMAssertPreventUserIdleDisplaySleep as CFString,
                    "Nauda" as CFString,
                    reason,
                    nil, nil, 0, nil,
                    &assertionID
                )
                if success == kIOReturnSuccess {
                    print("Nauda: Acquired keep-awake assertion. ID: \(assertionID)")
                    isActive = true
                } else {
                    print("Nauda: Failed to acquire assertion. Code: \(success)")
                    isActive = false
                    assertionID = 0
                }
            } else {
                isActive = true
            }
        } else {
            if assertionID != 0 {
                let result = IOPMAssertionRelease(assertionID)
                print("Nauda: Released keep-awake assertion. Result: \(result), ID: \(assertionID)")
                assertionID = 0
            }
            isActive = false
        }
    }
    
    func isTimeWithinSchedule() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Verify day of the week if schedule is restricted to weekdays
        if scheduleInterval == "weekdays" {
            let weekday = calendar.component(.weekday, from: now)
            // 1 is Sunday, 7 is Saturday. Weekdays are 2, 3, 4, 5, 6
            guard weekday >= 2 && weekday <= 6 else {
                return false
            }
        }
        
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        if startMinutes <= endMinutes {
            // Standard daytime schedule (e.g., 9:00 to 17:00)
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        } else {
            // Overnight schedule (e.g., 22:00 to 06:00)
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        }
    }
}
