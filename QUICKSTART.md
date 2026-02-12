# Quick Start Guide

Follow these steps to build and run ScreenCleanerApp:

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Basic knowledge of macOS development

## Step 1: Open the Project

1. Navigate to the project folder:
   ```bash
   cd /Users/zhipeng.wen/code/ScreenCleanerApp
   ```

2. Open the project in Xcode:
   ```bash
   open ScreenCleanerApp.xcodeproj
   ```

   Or double-click `ScreenCleanerApp.xcodeproj` in Finder.

## Step 2: Configure Signing

1. In Xcode, select the **ScreenCleanerApp** project in the navigator
2. Select the **ScreenCleanerApp** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown (you may need to add your Apple ID first)
5. Xcode will automatically generate a bundle identifier

## Step 3: Build and Run

1. Select your Mac as the target device from the toolbar
2. Click the **Run** button (▶) or press `⌘ + R`
3. Wait for the build to complete

## Step 4: Grant Permissions

When you first run the app:

1. A dialog will appear requesting Accessibility permission
2. Click **"Open Settings"**
3. In System Settings, navigate to:
   - **Privacy & Security** → **Accessibility**
4. Find **ScreenCleanerApp** in the list
5. Toggle the switch to **ON**
6. You may need to restart the app

## Step 5: Test the App

### Method 1: Menu Bar
1. Look for the sparkles icon (✨) in the menu bar
2. Click it and select **"开始清洁 (⌘⇧L)"**
3. All screens should turn black
4. Press **⌘ + ⌥ + Esc** to exit

### Method 2: Keyboard Shortcut
1. Press **⌘ + Shift + L** anywhere
2. All screens should turn black
3. Press **⌘ + ⌥ + Esc** to exit

## Troubleshooting

### "App can't be opened because Apple cannot check it"

If you see this error when running the app outside Xcode:
1. Go to **System Settings** → **Privacy & Security**
2. Scroll down to find the blocked app message
3. Click **"Open Anyway"**

### Clean Mode Doesn't Start

1. Check that the Accessibility permission is granted
2. Look at the menu bar - the status should show **"✓ 权限已授予"**
3. If not, click the menu item to open System Settings and grant permission

### Keyboard Not Blocked

This usually means Accessibility permission is not granted:
1. Click the menu bar icon
2. Check the permission status
3. If needed, re-grant the permission and restart the app

### Can't Exit Clean Mode

If you're stuck in clean mode:
1. First try: **⌘ + ⌥ + Esc**
2. If that doesn't work: **Force quit**
   - Press and hold **Power button** for 5 seconds, OR
   - Press **Control + ⌘ + Power** to restart

## Development Tips

### Viewing Console Output

To see debug logs:
1. In Xcode, open **View** → **Debug Area** → **Show Debug Area** (`⌘ + Shift + Y`)
2. Run the app and look for console messages with emoji prefixes:
   - 🚀 App launch
   - ✅ Success
   - ❌ Errors
   - 🔑 Hotkey events

### Debugging Permission Issues

If you're having permission problems:
```bash
# Check if app is trusted
sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
  "SELECT * FROM access WHERE service='kTCCServiceAccessibility';"
```

### Modifying the Code

Key files to customize:
- **Constants.swift** - Change hotkey configuration
- **CleanModeManager.swift** - Modify clean mode behavior
- **SettingsView.swift** - Customize UI

## Next Steps

- Customize the app icon in `Assets.xcassets`
- Add launch at login functionality
- Implement auto-exit timer
- Add usage statistics

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [CGEvent Reference](https://developer.apple.com/documentation/coregraphics/cgevent)
- [Accessibility API](https://developer.apple.com/documentation/applicationservices/axuielementref)

## Support

If you encounter issues:
1. Check the README.md for detailed documentation
2. Review the console logs in Xcode
3. Ensure all permissions are granted
4. Try restarting the app and your Mac

Happy coding! 🎉
