#!/bin/bash

# Backup script for scores
# Creates timestamped tar.gz backups and manages backup retention

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/Users/Michele/Sites/scores"
BACKUP_DIR="${APP_DIR}/project-files/backups"
MAX_BACKUPS=30  # Keep last 30 backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="scores_backup_${TIMESTAMP}.tar.gz"

echo -e "${GREEN}=== Scores Backup ===${NC}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Change to app directory
cd "${APP_DIR}"

# Files and directories to backup
BACKUP_TARGETS=(
    "src"
    "js"
    "css"
    "appinfo"
    "templates"
    "lib"
    "package.json"
    "package-lock.json"
    "vite.config.js"
    "deploy-production.sh"
)

echo -e "${YELLOW}Creating backup: ${BACKUP_NAME}${NC}"

# Create tar.gz archive
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}" \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    "${BACKUP_TARGETS[@]}" 2>/dev/null || {
    echo -e "${RED}Error creating backup${NC}"
    exit 1
}

# Get backup size
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}" | cut -f1)
echo -e "${GREEN}✓ Backup created: ${BACKUP_SIZE}${NC}"

# Cleanup old backups (keep last MAX_BACKUPS)
echo -e "${YELLOW}Managing backup retention (keeping last ${MAX_BACKUPS} backups)...${NC}"
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/scores_backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    REMOVE_COUNT=$((BACKUP_COUNT - MAX_BACKUPS))
    echo "  Removing $REMOVE_COUNT old backup(s)..."
    ls -1t "${BACKUP_DIR}"/scores_backup_*.tar.gz | tail -n "$REMOVE_COUNT" | xargs rm -f
    echo -e "${GREEN}  ✓ Cleanup complete${NC}"
else
    echo "  No cleanup needed (${BACKUP_COUNT} backups)"
fi

# Show backup summary
echo ""
echo -e "${GREEN}=== Backup Summary ===${NC}"
echo "Location: ${BACKUP_DIR}/${BACKUP_NAME}"
echo "Size: ${BACKUP_SIZE}"
echo "Total backups: $(ls -1 "${BACKUP_DIR}"/scores_backup_*.tar.gz 2>/dev/null | wc -l)"
echo ""
echo "To restore this backup:"
echo "  tar -xzf ${BACKUP_DIR}/${BACKUP_NAME}"
