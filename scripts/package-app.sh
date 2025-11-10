#!/bin/bash

##
# Package script for mxmlscores Nextcloud app
# Creates a distributable tar.gz archive ready for installation on other Nextcloud instances
##

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="mxmlscores"
LOCAL_DIR="/Users/Michele/Sites/mxmlscores"
BUILD_DIR="${LOCAL_DIR}/build_package"
DIST_DIR="${LOCAL_DIR}/project-files/dist"

# Get version from info.xml (macOS compatible)
VERSION=$(grep -o '<version>[^<]*</version>' "${LOCAL_DIR}/appinfo/info.xml" | sed 's/<[^>]*>//g' || echo "unknown")

PACKAGE_NAME="${APP_NAME}-${VERSION}.tar.gz"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Package Builder for ${APP_NAME}         ║${NC}"
echo -e "${BLUE}║  Version: ${VERSION}                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Clean previous builds
echo -e "${YELLOW}Step 1: Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/${APP_NAME}"
mkdir -p "${DIST_DIR}"

# Step 2: Build the app
echo -e "${YELLOW}Step 2: Building app...${NC}"
cd "${LOCAL_DIR}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build completed successfully${NC}"

# Step 3: Copy necessary files
echo -e "${YELLOW}Step 3: Copying files for distribution...${NC}"

# Copy built JS and CSS
echo "  → Copying built files (js, css)..."
cp -r js "${BUILD_DIR}/${APP_NAME}/"
cp -r css "${BUILD_DIR}/${APP_NAME}/"

# Copy PHP backend
echo "  → Copying PHP backend (lib)..."
cp -r lib "${BUILD_DIR}/${APP_NAME}/"

# Copy app metadata
echo "  → Copying app metadata (appinfo)..."
cp -r appinfo "${BUILD_DIR}/${APP_NAME}/"

# Copy templates
echo "  → Copying templates..."
cp -r templates "${BUILD_DIR}/${APP_NAME}/"

# Copy icons
echo "  → Copying app icons (img)..."
cp -r img "${BUILD_DIR}/${APP_NAME}/"

# Copy public folder (test files, if any)
if [ -d "public" ]; then
    echo "  → Copying public folder..."
    cp -r public "${BUILD_DIR}/${APP_NAME}/"
fi

# Copy documentation
echo "  → Copying documentation..."
[ -f "README.md" ] && cp README.md "${BUILD_DIR}/${APP_NAME}/"
[ -f "INSTALL.md" ] && cp INSTALL.md "${BUILD_DIR}/${APP_NAME}/"

# Step 4: Clean up development files from build
echo -e "${YELLOW}Step 4: Cleaning development files...${NC}"
find "${BUILD_DIR}" -name ".DS_Store" -delete
find "${BUILD_DIR}" -name "*.map" -delete

# Step 5: Create tar.gz archive
echo -e "${YELLOW}Step 5: Creating archive...${NC}"
cd "${BUILD_DIR}"
tar -czf "${DIST_DIR}/${PACKAGE_NAME}" "${APP_NAME}"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Archive creation failed!${NC}"
    exit 1
fi

# Step 6: Generate checksum
echo -e "${YELLOW}Step 6: Generating checksum...${NC}"
cd "${DIST_DIR}"
md5 "${PACKAGE_NAME}" > "${PACKAGE_NAME}.md5"
CHECKSUM=$(cat "${PACKAGE_NAME}.md5")

# Step 7: Clean up build directory
echo -e "${YELLOW}Step 7: Cleaning up...${NC}"
rm -rf "${BUILD_DIR}"

# Final report
FILE_SIZE=$(du -h "${DIST_DIR}/${PACKAGE_NAME}" | cut -f1)

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Package created successfully!       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Package Details:${NC}"
echo -e "  File:     ${GREEN}${PACKAGE_NAME}${NC}"
echo -e "  Location: ${GREEN}${DIST_DIR}${NC}"
echo -e "  Size:     ${GREEN}${FILE_SIZE}${NC}"
echo -e "  Checksum: ${GREEN}${CHECKSUM}${NC}"
echo ""
echo -e "${BLUE}Installation Instructions:${NC}"
echo -e "  1. Transfer ${PACKAGE_NAME} to target server"
echo -e "  2. cd /path/to/nextcloud/apps"
echo -e "  3. tar -xzf ${PACKAGE_NAME}"
echo -e "  4. chown -R www-data:www-data ${APP_NAME}"
echo -e "  5. Enable app from Nextcloud admin panel"
echo ""
