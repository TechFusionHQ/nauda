#!/bin/bash

# Exit immediately if any command fails
set -e

APP_NAME="Nauda"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
MACOS_DIR="${APP_DIR}/Contents/MacOS"

echo "🧹 Cleaning previous builds..."
rm -rf "${BUILD_DIR}"

echo "📁 Creating app structure..."
mkdir -p "${MACOS_DIR}"

echo "🔨 Compiling Swift sources..."
# Compile all swift files together, optimization level -O for performance
# and linking AppKit/SwiftUI frameworks.
swiftc -O -sdk "$(xcrun --show-sdk-path --sdk macosx)" Sources/*.swift -o "${MACOS_DIR}/${APP_NAME}"

echo "📁 Copying resources..."
RESOURCES_DIR="${APP_DIR}/Contents/Resources"
mkdir -p "${RESOURCES_DIR}"
cp Sources/nauda.png "${RESOURCES_DIR}/"

echo "📝 Creating Info.plist..."
cat <<EOF > "${APP_DIR}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>dev.techfusion.nauda</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build completed successfully! You can run the app at: ${APP_DIR}"
echo "🚀 To run the app, type: open ${APP_DIR}"
