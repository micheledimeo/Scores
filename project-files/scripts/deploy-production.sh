#!/bin/bash

##
# Deploy script for scores Nextcloud app
# Builds the app and deploys to production server
##

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="scores"
LOCAL_DIR="/Users/Michele/Sites/scores"
REMOTE_USER="root"
REMOTE_HOST="ottoniascoppio"  # Uses SSH config
REMOTE_DIR="/home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html/apps/${APP_NAME}"

echo -e "${GREEN}=== Deploying ${APP_NAME} to production ===${NC}"

# Step 1: Build the app
echo -e "${YELLOW}Step 1: Building app...${NC}"
cd "${LOCAL_DIR}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build completed successfully${NC}"

# Step 2: Copy built files to server using tar through SSH
echo -e "${YELLOW}Step 2: Deploying files to server...${NC}"

# Create directories on remote
echo "  → Preparing remote directories..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ${REMOTE_DIR}/{js,css,appinfo,templates,lib/Controller,public/test-scores,img}"

# Copy JS files
echo "  → Copying JS files..."
tar czf - -C js . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/js/"

# Copy CSS files
echo "  → Copying CSS files..."
tar czf - -C css . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/css/"

# Copy appinfo
echo "  → Copying appinfo..."
tar czf - -C appinfo . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/appinfo/"

# Copy templates
echo "  → Copying templates..."
tar czf - -C templates . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/templates/"

# Copy lib/Controller
echo "  → Copying PHP controllers..."
tar czf - -C lib/Controller . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/lib/Controller/"

# Copy img folder (app icons)
echo "  → Copying app icons..."
tar czf - -C img . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/img/"

# Step 3: Copy test sample file
echo -e "${YELLOW}Step 3: Setting up test files...${NC}"

if [ -f "public/test-scores/sample.musicxml" ]; then
    echo "  → Copying test sample..."
    tar czf - -C public/test-scores . | ssh "${REMOTE_USER}@${REMOTE_HOST}" "tar xzf - -C ${REMOTE_DIR}/public/test-scores/"
else
    echo -e "${YELLOW}  ⚠ Warning: sample.musicxml not found locally${NC}"
fi

# Step 4: Set ownership and permissions
echo -e "${YELLOW}Step 4: Setting ownership and permissions...${NC}"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "chown -R ottoniascoppio:ottoniascoppio ${REMOTE_DIR}/js ${REMOTE_DIR}/css ${REMOTE_DIR}/appinfo ${REMOTE_DIR}/templates ${REMOTE_DIR}/public && chmod -R 755 ${REMOTE_DIR}/js ${REMOTE_DIR}/css ${REMOTE_DIR}/public"

echo -e "${GREEN}=== Deployment completed successfully! ===${NC}"
echo ""
echo "App URL: https://cloud.ottoniascoppio.org/index.php/apps/scores"
echo "Test mode: https://cloud.ottoniascoppio.org/index.php/apps/scores/?testSample=1"
echo ""
