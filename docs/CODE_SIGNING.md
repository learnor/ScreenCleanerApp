# Code Signing Guide for ScreenCleanerApp

This guide explains how to set up code signing and notarization for ScreenCleanerApp.

## Overview

There are two distribution modes:

1. **Free Mode** (Default) - No code signing, users need to manually approve
2. **Professional Mode** - Full code signing and notarization (requires Apple Developer Program)

## Option 1: Free Mode (No Code Signing)

### What Users Experience
- Download and open the app
- Right-click → Open (first time only)
- Click "Open" when macOS shows "unidentified developer" warning
- App runs normally afterward

### Advantages
- ✅ Completely free
- ✅ No Apple Developer account needed
- ✅ Works for personal projects and open source

### Limitations
- ⚠️ Users see security warning on first launch
- ⚠️ Cannot distribute via Mac App Store
- ⚠️ Less professional appearance

### Setup
No setup required! The GitHub Actions workflow skips signing steps by default.

---

## Option 2: Professional Mode (Code Signing + Notarization)

### Requirements
- Apple Developer Program membership ($99/year)
- Valid Developer ID Application certificate
- Apple ID with app-specific password

### What Users Experience
- Download and double-click to open
- App runs immediately without warnings
- macOS recognizes it as verified by Apple

### Advantages
- ✅ Best user experience
- ✅ No security warnings
- ✅ Builds trust with users
- ✅ Required for Mac App Store distribution

---

## Setting Up Professional Mode

### Step 1: Join Apple Developer Program

1. Visit https://developer.apple.com/programs/
2. Enroll ($99/year)
3. Wait for approval (usually 1-2 days)

### Step 2: Create Developer ID Certificate

1. Open Xcode
2. Go to **Xcode → Settings → Accounts**
3. Add your Apple ID if not already added
4. Select your team → **Manage Certificates**
5. Click **+** → **Developer ID Application**
6. Certificate is automatically created and installed in Keychain

### Step 3: Export Certificate for GitHub Actions

```bash
# Open Keychain Access
open /Applications/Utilities/Keychain\ Access.app

# Find your "Developer ID Application" certificate
# Right-click → Export "Developer ID Application: Your Name"
# Save as .p12 file with a strong password
# Note: Remember this password for later!
```

### Step 4: Convert Certificate to Base64

```bash
# Convert .p12 to base64
base64 -i ~/Downloads/Certificates.p12 -o ~/Downloads/certificate.txt

# Copy the contents of certificate.txt
cat ~/Downloads/certificate.txt
```

### Step 5: Create App-Specific Password

1. Go to https://appleid.apple.com
2. Sign in with your Apple ID
3. Navigate to **Security** → **App-Specific Passwords**
4. Click **Generate Password**
5. Label it "ScreenCleanerApp Notarization"
6. Save the generated password securely

### Step 6: Find Your Team ID

```bash
# Option 1: Via Xcode
# Open Xcode → Settings → Accounts → Select Team
# Team ID is shown (10 characters, e.g., ABCDE12345)

# Option 2: Via Developer Portal
# Visit https://developer.apple.com/account
# Go to Membership → Team ID
```

### Step 7: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add the following secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Contents of certificate.txt | Base64-encoded .p12 certificate |
| `P12_PASSWORD` | Your .p12 password | Password you set when exporting |
| `KEYCHAIN_PASSWORD` | Any random password | Temporary keychain password (e.g., `temp123`) |
| `APPLE_ID` | your@email.com | Your Apple ID email |
| `APPLE_APP_SPECIFIC_PASSWORD` | xxxx-xxxx-xxxx-xxxx | App-specific password from Step 5 |
| `TEAM_ID` | ABCDE12345 | Your 10-character Team ID |

### Step 8: Enable Signing in GitHub Actions

Edit `.github/workflows/release.yml` and uncomment the code signing steps:

1. Find `# Import signing certificate` section → Uncomment
2. Find `# Sign the application` section → Uncomment
3. Find `# Notarize the application` section → Uncomment

### Step 9: Update Project Settings

In Xcode project settings:

1. Select **ScreenCleanerApp** target
2. Go to **Signing & Capabilities**
3. Uncheck **Automatically manage signing**
4. Select your **Developer ID Application** certificate
5. Set **Team** to your Apple Developer team

---

## Testing Code Signing Locally

```bash
# Build the app
xcodebuild -project ScreenCleanerApp.xcodeproj \
  -scheme ScreenCleanerApp \
  -configuration Release \
  -archivePath ./build/ScreenCleanerApp.xcarchive \
  archive

# Export the app
xcodebuild -exportArchive \
  -archivePath ./build/ScreenCleanerApp.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist scripts/ExportOptions.plist

# Verify code signature
codesign --verify --deep --strict ./build/ScreenCleanerApp.app
codesign -dv --verbose=4 ./build/ScreenCleanerApp.app

# Check if it's notarized (after notarization)
spctl --assess --verbose=4 ./build/ScreenCleanerApp.app
```

---

## Notarization Process

### What is Notarization?

Notarization is Apple's automated security check:
- Scans for malware and code-signing issues
- Does NOT review app functionality (that's App Review)
- Usually completes in 5-15 minutes
- Required for apps distributed outside Mac App Store

### Notarization in GitHub Actions

The workflow automatically:
1. Zips the signed app
2. Uploads to Apple's notary service
3. Waits for notarization to complete
4. Staples the notarization ticket to the app
5. Packages the notarized app for distribution

### Manual Notarization (Optional)

```bash
# Zip the app
ditto -c -k --keepParent ./build/ScreenCleanerApp.app ./build/ScreenCleanerApp.zip

# Submit for notarization
xcrun notarytool submit ./build/ScreenCleanerApp.zip \
  --apple-id "your@email.com" \
  --team-id "ABCDE12345" \
  --password "xxxx-xxxx-xxxx-xxxx" \
  --wait

# Staple the ticket (if successful)
xcrun stapler staple ./build/ScreenCleanerApp.app

# Verify
spctl --assess -vv ./build/ScreenCleanerApp.app
```

---

## Troubleshooting

### "no identity found" Error

**Problem**: `error: No signing certificate "Developer ID Application" found`

**Solution**:
1. Ensure you've created the certificate in Xcode (Step 2)
2. Check it exists in Keychain Access
3. Verify GitHub secret `BUILD_CERTIFICATE_BASE64` is correct
4. Make sure `P12_PASSWORD` matches your export password

### Notarization Fails

**Problem**: Notarization returns errors

**Solution**:
```bash
# Get detailed notarization log
xcrun notarytool log <submission-id> \
  --apple-id "your@email.com" \
  --team-id "ABCDE12345" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

Common issues:
- **Unsigned binary**: Ensure all binaries are signed
- **Hardened Runtime issues**: Check entitlements
- **Missing Info.plist keys**: Verify bundle structure

### "App is damaged" Error

**Problem**: macOS says "ScreenCleanerApp is damaged and can't be opened"

**Solution**:
- This usually means the app wasn't notarized correctly
- Or the quarantine attribute wasn't removed
- Run: `xattr -cr /Applications/ScreenCleanerApp.app`

---

## Comparison Table

| Feature | Free Mode | Professional Mode |
|---------|-----------|-------------------|
| Cost | Free | $99/year |
| User Experience | Right-click to open | Double-click to open |
| Security Warning | Yes (first time) | No |
| Setup Time | 0 minutes | 1-2 hours |
| Mac App Store | ❌ No | ✅ Yes |
| Gatekeeper Bypass | Manual | Automatic |
| Trust Level | Low | High |
| Recommended For | Personal/Testing | Production/Distribution |

---

## Recommendation

- **Start with Free Mode** if you're:
  - Testing or developing
  - Sharing with a small group
  - Not ready to invest $99/year

- **Upgrade to Professional Mode** when you're:
  - Publicly distributing the app
  - Want the best user experience
  - Planning to monetize or scale
  - Ready for Mac App Store

---

## Resources

- [Apple Developer Program](https://developer.apple.com/programs/)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Resolving Common Notarization Issues](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/resolving_common_notarization_issues)

---

## Questions?

If you encounter issues not covered here, please:
1. Check GitHub Actions logs for detailed error messages
2. Review Apple's official documentation
3. Open an issue in the repository with logs and screenshots
