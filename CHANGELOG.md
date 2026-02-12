# Changelog

All notable changes to ScreenCleanerApp will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-12

### Added
- Initial release of ScreenCleanerApp
- Full-screen clean mode to prevent keyboard input while cleaning screen
- Customizable hotkey (default: ⌘⇧L) to toggle clean mode
- Menu bar interface with quick access to settings
- Accessibility permission management
- Pure menu bar app (no Dock icon)
- Clean overlay with instructions and exit key display
- Settings panel for hotkey customization
- Auto-disable clean mode on loss of accessibility permissions

### Features
- **Clean Mode**: Press hotkey to activate full-screen overlay that blocks all input
- **Smart Exit**: Press the same hotkey again to exit clean mode
- **Menu Bar Integration**: Persistent menu bar icon for easy access
- **Customizable Hotkey**: Configure your preferred keyboard shortcut
- **Permission Management**: Guided setup for required accessibility permissions
- **Lightweight**: Minimal resource usage, runs quietly in background

### Technical
- Built with SwiftUI and AppKit
- Uses CGEvent tap for keyboard interception
- macOS 13.0+ support
- Native Apple Silicon and Intel support

[1.0.0]: https://github.com/YOUR_USERNAME/ScreenCleanerApp/releases/tag/v1.0.0
