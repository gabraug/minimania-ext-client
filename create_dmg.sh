#!/bin/bash

APP_NAME="MiniMania"
BUNDLE_ID="com.minimania.client"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="${APP_NAME}.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"
DMG_TEMP_DIR="$BUILD_DIR/dmg_temp"
DMG_VOLUME_NAME="$APP_NAME"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Creating DMG for $APP_NAME...${NC}"

echo -e "${YELLOW}Step 1: Building application...${NC}"
if [ ! -f "build.sh" ]; then
    echo -e "${RED}Error: build.sh not found!${NC}"
    exit 1
fi

./build.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Build failed!${NC}"
    exit 1
fi

if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}Error: Application not found at $APP_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Application built successfully!${NC}"

echo -e "${YELLOW}Step 2: Cleaning up old files...${NC}"
rm -rf "$DMG_TEMP_DIR"
rm -f "$DMG_PATH"

echo -e "${YELLOW}Step 3: Creating DMG structure...${NC}"
mkdir -p "$DMG_TEMP_DIR"

cp -R "$APP_DIR" "$DMG_TEMP_DIR/"

ln -s /Applications "$DMG_TEMP_DIR/Applications"

echo -e "${YELLOW}Step 4: Creating DMG file...${NC}"
hdiutil create -volname "$DMG_VOLUME_NAME" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to create DMG!${NC}"
    rm -rf "$DMG_TEMP_DIR"
    exit 1
fi

echo -e "${YELLOW}Step 5: Cleaning up...${NC}"
rm -rf "$DMG_TEMP_DIR"

if [ -f "$DMG_PATH" ]; then
    DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
    echo -e "${GREEN}✓ DMG created successfully!${NC}"
    echo -e "${GREEN}  Location: $DMG_PATH${NC}"
    echo -e "${GREEN}  Size: $DMG_SIZE${NC}"
    echo ""
    echo -e "${GREEN}You can now distribute the DMG file.${NC}"
else
    echo -e "${RED}Error: DMG file was not created!${NC}"
    exit 1
fi

