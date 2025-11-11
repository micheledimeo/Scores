#!/bin/bash

# Deploy and Test script for mxmlscores
# 1. Builds the app
# 2. Deploys to production
# 3. Waits for deployment to stabilize
# 4. Runs online tests automatically

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/Users/Michele/Sites/mxmlscores"
TEST_DIR="${APP_DIR}/project-files/testsprite"

echo -e "${GREEN}=== Deploy & Test Workflow ===${NC}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: Build
echo -e "${BLUE}[1/4]${NC} ${YELLOW}Building application...${NC}"
cd "${APP_DIR}"
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build successful${NC}"
echo ""

# Step 2: Deploy
echo -e "${BLUE}[2/4]${NC} ${YELLOW}Deploying to production...${NC}"
"${APP_DIR}/project-files/scripts/deploy-production.sh"
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Deploy failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Deploy successful${NC}"
echo ""

# Step 3: Wait for deployment to stabilize
echo -e "${BLUE}[3/4]${NC} ${YELLOW}Waiting for deployment to stabilize (15 seconds)...${NC}"
for i in {15..1}; do
    echo -ne "  ${i}s remaining...\r"
    sleep 1
done
echo -e "  ${GREEN}✓ Ready for testing${NC}                "
echo ""

# Step 4: Run tests
echo -e "${BLUE}[4/4]${NC} ${YELLOW}Running online tests...${NC}"
cd "${TEST_DIR}"
npm run test:online

# Check test results
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== All steps completed successfully! ===${NC}"
    echo -e "✓ Build"
    echo -e "✓ Deploy"
    echo -e "✓ Tests"
else
    echo ""
    echo -e "${YELLOW}=== Tests completed with failures ===${NC}"
    echo -e "✓ Build"
    echo -e "✓ Deploy"
    echo -e "⚠ Tests (some failures)"
    echo ""
    echo "View detailed results with:"
    echo "  cd ${TEST_DIR} && npx playwright show-report"
fi
