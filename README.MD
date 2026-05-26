# Nauda (Nâu Đá)

<p align="center">
  <img src="Sources/nauda.png" width="250" alt="Nauda Logo" />
</p>

**Nauda** is a lightweight, modern, and beautiful macOS menu bar app designed to keep your Mac awake.

The name **Nauda** is derived from **"Nâu đá"** (also known as _Cà phê sữa đá_), a famous, rich, and delicious Vietnamese iced coffee with condensed milk. Just like a good cup of Vietnamese coffee keeps you energized and focused, **Nauda** keeps your Mac awake and ready whenever you need it. It is a must-try coffee experience in real life, and a must-have utility for your Mac!

---

## ✨ Features

- **Keep Awake**: Prevents display and system idle sleep on macOS with a single click.
- **Dynamic Icons**: Shows a hot, filled coffee cup (`cup.and.saucer.fill`) in the status bar when active, and an empty cup (`cup.and.saucer`) when paused or inactive.
- **Elegantly Scheduled**: Set a start and end time (e.g., 9:00 AM – 5:00 PM) to automatically manage your Mac's sleep prevention.
- **Repeat Options**: Choose to apply the schedule **Everyday** or restrict it only to **Weekdays**.
- **Manual Sleep Auto-Pause & Resume**: If you manually put your Mac to sleep (or close the lid), Nauda automatically pauses itself so your computer can sleep peacefully. Once you wake your Mac back up, Nauda automatically resumes sleep prevention if it is still within the active scheduled window.
- **Premium Aesthetics**: Built with native SwiftUI, featuring smooth animations, a pulsing coffee glow, steam loops rising from your cup, and a glassmorphic background design that blends perfectly with macOS.

---

## 🛠️ Build & Run Options

You can build Nauda using either the native Xcode project (recommended for App Store development) or the lightweight one-click build script.

### Option A: Native Xcode Project (App Store Ready)

1. Double-click the **[Nauda.xcodeproj](Nauda.xcodeproj)** package to open it in Xcode.
2. Select the `Nauda` target and build/run with `Cmd + R`.
3. To package the app for upload to the App Store, choose **Product -> Archive** from the menu bar.

_Note: This project is pre-configured with the **App Sandbox**, **Hardened Runtime**, and includes the official asset catalog containing the app icon in all required dimensions._

### Option B: Quick Command Line Build

Run the build script to quickly compile and package the app into a standard macOS `.app` bundle:

```bash
./build.sh
```

Launch the compiled app directly:

```bash
open build/Nauda.app
```

Once opened, you will see a coffee cup icon appear in your macOS status bar at the top of your screen.

---

## 📖 Help & Usage Guide

- **Toggle Awake State**: Click the menu bar cup icon to open the dashboard, then click the large coffee cup button. Alternatively, close the dashboard by clicking outside.
- **Schedule Setup**: Toggle "Schedule Keep Awake" inside the dashboard. Use the time pickers to set your custom window, and select between **Everyday** or **Weekdays** repeating intervals.
- **Pause Temporarily**: Click the cup inside the dashboard to pause sleep-prevention manually at any time.
- **Quit Nauda**: Hover over the bottom-right corner of the panel and click the small power icon button (`power`).

---

## 🚀 App Store Link

_Coming Soon!_

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

Copyright © 2026 [TECHFUSION COMPANY LIMITED](https://www.techfusion.dev). All rights reserved.
