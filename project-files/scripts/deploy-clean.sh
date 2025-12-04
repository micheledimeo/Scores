#!/bin/bash

##
# Clean deployment script for scores Nextcloud app
# Deploys ONLY production-ready files (no development files)
##

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="scores"
LOCAL_DIR="/Users/Michele/Sites/scores"
REMOTE_USER="root"
REMOTE_HOST="ottoniascoppio"
REMOTE_DIR="/var/www/nextcloud/apps/${APP_NAME}"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Clean Deploy - ${APP_NAME}               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Build the app
echo -e "${YELLOW}Step 1: Building app...${NC}"
cd "${LOCAL_DIR}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build completed${NC}"

# Step 2: Remove old app directory and create fresh one
echo -e "${YELLOW}Step 2: Preparing clean deployment...${NC}"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "rm -rf ${REMOTE_DIR} && mkdir -p ${REMOTE_DIR}/{js,css,lib,appinfo,templates,img}"

# Step 3: Deploy ONLY necessary files
echo -e "${YELLOW}Step 3: Deploying production files...${NC}"

# Copy JS files (built)
echo "  → js/"
rsync -az "${LOCAL_DIR}/js/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/js/"

# Copy CSS files (built)
echo "  → css/"
rsync -az "${LOCAL_DIR}/css/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/css/"

# Copy PHP backend
echo "  → lib/"
rsync -az "${LOCAL_DIR}/lib/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/lib/"

# Copy app metadata
echo "  → appinfo/"
rsync -az "${LOCAL_DIR}/appinfo/info.xml" "${LOCAL_DIR}/appinfo/routes.php" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/appinfo/"

# Copy templates
echo "  → templates/"
rsync -az "${LOCAL_DIR}/templates/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/templates/"

# Copy app icon
echo "  → img/"
rsync -az "${LOCAL_DIR}/img/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/img/"

# Step 4: Set ownership and permissions
echo -e "${YELLOW}Step 4: Setting permissions...${NC}"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "chown -R www-data:www-data ${REMOTE_DIR} && chmod -R 755 ${REMOTE_DIR}"

# Step 5: Touch info.xml to force Nextcloud reload
echo -e "${YELLOW}Step 5: Triggering app reload...${NC}"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "touch ${REMOTE_DIR}/appinfo/info.xml"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Deployment completed successfully!     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Deployed Files:${NC}"
echo "  • Built JS and CSS"
echo "  • PHP backend (lib/)"
echo "  • App metadata (appinfo/)"
echo "  • Templates"
echo "  • App icons"
echo ""
echo -e "${BLUE}NOT Deployed (development files):${NC}"
echo "  ✗ node_modules/"
echo "  ✗ src/ (source files)"
echo "  ✗ tests/, docs/, scripts/"
echo "  ✗ .git, .github/"
echo "  ✗ package.json, vite.config.js, etc."
echo ""
echo -e "${GREEN}App URL:${NC} https://ottoniascoppio.cloud/index.php/apps/scores"
echo ""
