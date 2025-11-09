#!/bin/bash

##
# Update repository URLs in info.xml
# Usage: ./update-repo-urls.sh [github-username] [author-email]
##

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get parameters
GITHUB_USERNAME="${1}"
AUTHOR_EMAIL="${2}"

# Validate inputs
if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}Error: GitHub username is required${NC}"
    echo ""
    echo "Usage: $0 <github-username> [author-email]"
    echo ""
    echo "Example:"
    echo "  $0 michele michele@example.com"
    echo ""
    exit 1
fi

if [ -z "$AUTHOR_EMAIL" ]; then
    echo -e "${YELLOW}Warning: No email provided. Email field will remain empty.${NC}"
    echo -e "${YELLOW}You can add it later by running: $0 $GITHUB_USERNAME your@email.com${NC}"
    echo ""
fi

INFO_XML="appinfo/info.xml"
REPO_NAME="mxmlscores"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Update Repository URLs in info.xml    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  GitHub User:  ${GREEN}${GITHUB_USERNAME}${NC}"
echo -e "  Repository:   ${GREEN}${REPO_NAME}${NC}"
if [ -n "$AUTHOR_EMAIL" ]; then
    echo -e "  Author Email: ${GREEN}${AUTHOR_EMAIL}${NC}"
fi
echo ""

# Backup original file
cp "$INFO_XML" "${INFO_XML}.backup"
echo -e "${YELLOW}→ Created backup: ${INFO_XML}.backup${NC}"

# Update URLs
GITHUB_BASE="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/main"

# Update website URL
sed -i '' "s|<website>.*</website>|<website>${GITHUB_BASE}</website>|" "$INFO_XML"
echo -e "${GREEN}✓ Updated website URL${NC}"

# Update bugs URL
sed -i '' "s|<bugs>.*</bugs>|<bugs>${GITHUB_BASE}/issues</bugs>|" "$INFO_XML"
echo -e "${GREEN}✓ Updated bugs URL${NC}"

# Update repository URL
sed -i '' "s|<repository type=\"git\">.*</repository>|<repository type=\"git\">${GITHUB_BASE}.git</repository>|" "$INFO_XML"
echo -e "${GREEN}✓ Updated repository URL${NC}"

# Update screenshot URL
sed -i '' "s|<screenshot>.*</screenshot>|<screenshot>${GITHUB_RAW}/screenshots/player-view.png</screenshot>|" "$INFO_XML"
echo -e "${GREEN}✓ Updated screenshot URL${NC}"

# Update author email if provided
if [ -n "$AUTHOR_EMAIL" ]; then
    sed -i '' "s|<author mail=\"[^\"]*\">|<author mail=\"${AUTHOR_EMAIL}\">|" "$INFO_XML"
    echo -e "${GREEN}✓ Updated author email${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         URLs updated successfully!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Updated URLs:${NC}"
echo -e "  Website:    ${GREEN}${GITHUB_BASE}${NC}"
echo -e "  Issues:     ${GREEN}${GITHUB_BASE}/issues${NC}"
echo -e "  Repository: ${GREEN}${GITHUB_BASE}.git${NC}"
echo -e "  Screenshot: ${GREEN}${GITHUB_RAW}/screenshots/player-view.png${NC}"
if [ -n "$AUTHOR_EMAIL" ]; then
    echo -e "  Author:     ${GREEN}${AUTHOR_EMAIL}${NC}"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review changes: ${BLUE}git diff appinfo/info.xml${NC}"
echo -e "  2. Commit changes: ${BLUE}git add appinfo/info.xml && git commit -m \"Update repository URLs\"${NC}"
echo -e "  3. Push to GitHub:  ${BLUE}git push${NC}"
echo ""
