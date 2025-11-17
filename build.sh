#!/bin/bash

# Script to compile the macOS application

APP_NAME="MiniMania"
BUNDLE_ID="com.minimania.client"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Create directories
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "Compiling application..."
SWIFT_FILES=(
    main.swift
    AppDelegate.swift
)

if [ -d "Models" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find Models -name "*.swift" -print0)
fi

if [ -d "Views" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find Views -name "*.swift" -print0)
fi

if [ -d "Controllers" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find Controllers -name "*.swift" -print0)
fi

if [ -d "Services" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find Services -name "*.swift" -print0)
fi

if [ -d "Extensions" ]; then
    while IFS= read -r -d '' file; do
        SWIFT_FILES+=("$file")
    done < <(find Extensions -name "*.swift" -print0)
fi

swiftc -o "$MACOS_DIR/$APP_NAME" \
    -framework Cocoa \
    -framework WebKit \
    "${SWIFT_FILES[@]}"

if [ $? -ne 0 ]; then
    echo "Error compiling!"
    exit 1
fi

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/"

# Copy App Icon if available
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
else
    echo "Warning: AppIcon.icns not found; application will use default icon."
fi

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Set permissions
chmod +x "$MACOS_DIR/$APP_NAME"

echo "Application compiled at: $APP_DIR"
echo "To run: open $APP_DIR"

