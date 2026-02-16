#!/bin/bash

# ScreenCleanerApp Installation Script
# This script downloads and installs the latest version of ScreenCleanerApp
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ScreenCleanerApp/main/scripts/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="learnor"
REPO_NAME="ScreenCleanerApp"
APP_NAME="ScreenCleanerApp"
INSTALL_DIR="/Applications"
APP_PATH="$INSTALL_DIR/$APP_NAME.app"

# Functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_macos_version() {
    print_step "Checking macOS version..."

    macos_version=$(sw_vers -productVersion)
    major_version=$(echo "$macos_version" | cut -d. -f1)

    if [ "$major_version" -lt 13 ]; then
        print_error "macOS 13.0 (Ventura) or later is required"
        print_error "Your version: $macos_version"
        exit 1
    fi

    print_success "macOS version: $macos_version"
}

get_latest_release() {
    print_step "Fetching latest release information..."

    # Get latest release info from GitHub API
    api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

    if ! release_info=$(curl -fsSL "$api_url" 2>/dev/null); then
        print_error "Failed to fetch release information"
        print_error "Repository: $REPO_OWNER/$REPO_NAME"
        print_error "Please check if the repository exists and has releases"
        exit 1
    fi

    # Extract version and download URL
    version=$(echo "$release_info" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    download_url=$(echo "$release_info" | grep '"browser_download_url":.*\.zip"' | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/' | head -1)

    if [ -z "$version" ] || [ -z "$download_url" ]; then
        print_error "Could not find release information"
        print_error "Please check if releases are published at:"
        print_error "https://github.com/$REPO_OWNER/$REPO_NAME/releases"
        exit 1
    fi

    print_success "Latest version: $version"
}

stop_running_app() {
    print_step "Checking for running instances..."

    if pgrep -x "$APP_NAME" > /dev/null; then
        print_warning "Stopping running instance of $APP_NAME..."
        killall "$APP_NAME" 2>/dev/null || true
        sleep 2
        print_success "Stopped running instance"
    else
        print_success "No running instances found"
    fi
}

download_and_install() {
    print_step "Downloading $APP_NAME $version..."

    # Create temporary directory
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT

    zip_file="$tmp_dir/$APP_NAME.zip"

    # Download the ZIP file
    if ! curl -fsSL -o "$zip_file" "$download_url"; then
        print_error "Failed to download from: $download_url"
        exit 1
    fi

    print_success "Downloaded successfully"

    print_step "Installing to $APP_PATH..."

    # Extract the ZIP file
    if ! unzip -q "$zip_file" -d "$tmp_dir"; then
        print_error "Failed to extract ZIP file"
        exit 1
    fi

    # Find the .app bundle
    app_bundle=$(find "$tmp_dir" -name "*.app" -maxdepth 2 | head -1)

    if [ -z "$app_bundle" ]; then
        print_error "Could not find .app bundle in download"
        exit 1
    fi

    # Remove existing installation
    if [ -d "$APP_PATH" ]; then
        print_warning "Removing existing installation..."
        rm -rf "$APP_PATH"
    fi

    # Copy to Applications
    if ! cp -R "$app_bundle" "$INSTALL_DIR/"; then
        print_error "Failed to copy app to $INSTALL_DIR"
        print_error "You may need to run this script with sudo"
        exit 1
    fi

    print_success "Installed to $APP_PATH"
}

remove_quarantine() {
    print_step "Removing quarantine attribute..."

    # Remove quarantine attribute to avoid "app is damaged" error
    if xattr -d com.apple.quarantine "$APP_PATH" 2>/dev/null; then
        print_success "Quarantine attribute removed"
    else
        print_warning "Could not remove quarantine attribute (may require first-run approval)"
    fi
}

verify_installation() {
    print_step "Verifying installation..."

    if [ -d "$APP_PATH" ]; then
        app_version=$(defaults read "$APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
        print_success "Installation verified (version: $app_version)"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

print_next_steps() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Launch the app:"
    echo "   ${BLUE}open -a ScreenCleanerApp${NC}"
    echo ""
    echo "2. Grant Accessibility permissions when prompted:"
    echo "   ${BLUE}System Settings > Privacy & Security > Accessibility${NC}"
    echo ""
    echo "3. Use the default hotkey to activate clean mode:"
    echo "   ${BLUE}⌘⇧L${NC} (Command + Shift + L)"
    echo ""
    echo "4. Customize settings via the menu bar icon"
    echo ""
    echo -e "${YELLOW}Note:${NC} On first launch, you may need to:"
    echo "   - Right-click the app and select 'Open'"
    echo "   - Click 'Open' in the security dialog"
    echo ""
    echo "To uninstall:"
    echo "   ${BLUE}rm -rf '$APP_PATH'${NC}"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   ScreenCleanerApp Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    check_macos_version
    get_latest_release
    stop_running_app
    download_and_install
    remove_quarantine
    verify_installation
    print_next_steps
}

# Run main function
main
