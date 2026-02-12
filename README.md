# ScreenCleanerApp 🧹✨

A macOS menu bar app that lets you clean your Mac screen without worrying about accidental keyboard and trackpad inputs.

## Features

- **One-Click Clean Mode**: Start cleaning with a single click or keyboard shortcut
- **Full-Screen Black Overlay**: Covers all connected displays
- **Complete Input Blocking**: Intercepts all keyboard inputs during clean mode
- **Safe Exit**: Only responds to specific key combination (⌘ + ⌥ + Esc)
- **Global Hotkey**: Quick start with ⌘ + Shift + L
- **Multi-Display Support**: Automatically covers all connected screens
- **Menu Bar Integration**: Minimal, unobtrusive interface

## Requirements

- macOS 13.0 or later
- Accessibility permission (required for keyboard interception)

## Installation

### Building from Source

1. Clone or download this repository
2. Open `ScreenCleanerApp.xcodeproj` in Xcode
3. Build and run the project (⌘ + R)
4. Grant Accessibility permission when prompted

### First Launch

On first launch, you'll be prompted to grant Accessibility permission:

1. Click "Open Settings" in the permission dialog
2. Navigate to System Settings → Privacy & Security → Accessibility
3. Find ScreenCleanerApp in the list and toggle it ON
4. Restart the app

## Usage

### Starting Clean Mode

**Method 1**: Click the sparkles icon (✨) in the menu bar → "开始清洁"

**Method 2**: Press ⌘ + Shift + L anywhere

### Exiting Clean Mode

Press ⌘ + ⌥ + Esc to exit clean mode and return to normal operation.

⚠️ **Important**: This is the ONLY way to exit clean mode. All other inputs will be blocked.

## How It Works

ScreenCleanerApp uses macOS system APIs to provide a safe cleaning experience:

1. **Full-Screen Windows**: Creates borderless black windows covering all displays
2. **Keyboard Interception**: Uses CGEventTap API to intercept and block all keyboard events
3. **Selective Filtering**: Only allows the exit key combination (⌘ + ⌥ + Esc) through
4. **Permission-Based**: Requires explicit user authorization via Accessibility settings

## Technical Details

### Architecture

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI + AppKit
- **Minimum Target**: macOS 13.0
- **Key Technologies**:
  - CGEventTap for keyboard interception
  - NSStatusItem for menu bar integration
  - Carbon Event Manager for global hotkeys

### Project Structure

```
ScreenCleanerApp/
├── App/                      # Application entry point
│   ├── ScreenCleanerAppApp.swift
│   ├── AppDelegate.swift
│   └── Info.plist
├── Core/                     # Core functionality
│   ├── CleanModeManager.swift
│   ├── FullScreenWindow.swift
│   ├── KeyboardInterceptor.swift
│   └── PermissionManager.swift
├── UI/                       # User interface
│   └── SettingsView.swift
└── Utilities/                # Helper classes
    ├── HotKeyManager.swift
    └── Constants.swift
```

### Key Components

#### CleanModeManager
Coordinates the clean mode lifecycle, managing windows and keyboard interception.

#### KeyboardInterceptor
Uses CGEventTap to intercept keyboard events at the system level. Blocks all input except the exit combination.

#### FullScreenWindow
Custom NSWindow subclass that creates a black overlay covering the entire screen at the highest window level.

#### PermissionManager
Handles Accessibility permission checks and requests.

#### HotKeyManager
Registers global keyboard shortcuts using Carbon Event Manager.

## Troubleshooting

### Clean Mode Won't Start

**Problem**: Clicking "Start Clean Mode" does nothing.

**Solution**: Check that Accessibility permission is granted:
- Click the menu bar icon → Check permission status
- If needed, click "⚠️ 需要授予权限..." to open System Settings
- Enable ScreenCleanerApp in Accessibility settings
- Restart the app

### Can't Exit Clean Mode

**Problem**: Stuck in clean mode and can't get out.

**Solutions**:
1. **Primary**: Press ⌘ + ⌥ + Esc (Command + Option + Escape)
2. **Backup**: Force quit the app:
   - Press and hold the Power button for 5 seconds, OR
   - Press Control + ⌘ + Power button to restart Mac

### Hotkey Not Working

**Problem**: ⌘ + Shift + L doesn't trigger clean mode.

**Possible Causes**:
- Another app is using the same shortcut
- Accessibility permission not granted
- App is not running

**Solution**:
- Check menu bar for the sparkles icon to verify app is running
- Grant Accessibility permission if not already done

### Multiple Displays Not Covered

**Problem**: External display not showing black overlay.

**Solution**:
- Ensure display is connected before starting clean mode
- Try disconnecting and reconnecting the display
- Restart the app after display configuration changes

## Privacy & Security

ScreenCleanerApp is designed with privacy in mind:

- ✅ **No Network Access**: App works completely offline
- ✅ **No Data Collection**: No user data is collected or transmitted
- ✅ **Open Source**: All code is available for inspection
- ✅ **Minimal Permissions**: Only requests Accessibility permission (required for functionality)
- ✅ **Sandboxed**: Runs with minimal system access

### Why Accessibility Permission?

Accessibility permission is required to use the CGEventTap API, which allows the app to:
- Intercept keyboard events system-wide
- Block unwanted input during clean mode
- Detect the exit key combination

**Important**: This permission is powerful and should only be granted to trusted apps. ScreenCleanerApp uses this permission exclusively for its intended purpose and does not log, transmit, or misuse keyboard input data.

## Limitations

- Some system-level shortcuts cannot be intercepted (e.g., Power button, Touch ID)
- App must be running to use the global hotkey
- Requires macOS 13.0 or later

## Future Enhancements

Potential features for future versions:

- [ ] Customizable key combinations
- [ ] Auto-exit timer (e.g., 30 seconds)
- [ ] Usage statistics
- [ ] Touchpad gesture support for exit
- [ ] Multi-language support
- [ ] Launch at login option
- [ ] Custom overlay colors/patterns

## License

MIT License - Feel free to use, modify, and distribute.

## Credits

Created with ❤️ by Claude

## Support

Found a bug or have a suggestion? Please open an issue on GitHub.

---

**Disclaimer**: This app requires Accessibility permission to function. Please ensure you trust the app before granting this permission. Always download from official sources.
