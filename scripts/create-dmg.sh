#!/bin/bash

# ScreenCleanerApp DMG Creation Script
# Creates a distributable DMG with Applications folder link

set -e

# Configuration
APP_NAME="ScreenCleanerApp"
VERSION="${1:-1.0.0}"  # Use argument or default to 1.0.0
BUILD_DIR="./build"
DMG_DIR="./dmg"
DIST_DIR="./dist"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-v$VERSION"
DMG_PATH="$DIST_DIR/$DMG_NAME.dmg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if app bundle exists
if [ ! -d "$APP_PATH" ]; then
    print_error "App bundle not found at: $APP_PATH"
    print_error "Please build the app first"
    exit 1
fi

print_step "Creating DMG for $APP_NAME v$VERSION..."

# Clean and create directories
print_step "Preparing directories..."
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
mkdir -p "$DIST_DIR"

# Copy app to DMG directory
print_step "Copying app bundle..."
cp -R "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications folder
print_step "Creating Applications folder link..."
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
print_step "Creating DMG image..."
rm -f "$DMG_PATH"

hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

print_success "DMG created: $DMG_PATH"

# Calculate SHA256
print_step "Calculating SHA256 checksum..."
if command -v shasum &> /dev/null; then
    sha256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
else
    sha256=$(sha256sum "$DMG_PATH" | awk '{print $1}')
fi

echo "$sha256" > "$DIST_DIR/$DMG_NAME.sha256"
print_success "SHA256: $sha256"

# Get DMG size
dmg_size=$(du -h "$DMG_PATH" | cut -f1)
print_success "DMG size: $dmg_size"

# Clean up
print_step "Cleaning up..."
rm -rf "$DMG_DIR"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ DMG Creation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Output:"
echo "  DMG: $DMG_PATH"
echo "  SHA256: $DIST_DIR/$DMG_NAME.sha256"
echo "  Size: $dmg_size"
echo ""
echo "To test the DMG:"
echo "  open $DMG_PATH"
echo ""
