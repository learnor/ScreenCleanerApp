cask "screen-cleaner" do
  version "1.0.0"
  sha256 "18d9d43113794748c2ccb08e742abb8cebf52fe1424e5b6af6176565fc844b3e"  # Will be updated by release workflow

  url "https://github.com/learnor/ScreenCleanerApp/releases/download/v#{version}/ScreenCleanerApp-v#{version}.zip"
  name "ScreenCleanerApp"
  desc "Menu bar app to prevent keyboard input while cleaning your screen"
  homepage "https://github.com/learnor/ScreenCleanerApp"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: ">= :ventura"

  app "ScreenCleanerApp.app"

  postflight do
    # Remove quarantine attribute to avoid "app is damaged" error
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/ScreenCleanerApp.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Preferences/com.yourcompany.ScreenCleanerApp.plist",
    "~/Library/Application Support/ScreenCleanerApp",
  ]

  caveats <<~EOS
    ScreenCleanerApp requires Accessibility permissions to function.

    To grant permissions:
      1. Open System Settings
      2. Go to Privacy & Security > Accessibility
      3. Enable ScreenCleanerApp

    Default hotkey: ⌘⇧L (Command + Shift + L)

    For more information, visit:
      https://github.com/learnor/ScreenCleanerApp
  EOS
end
