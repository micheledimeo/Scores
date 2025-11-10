#!/bin/bash

##
# Sign Nextcloud app for App Store submission
# Creates signature.json required by Nextcloud App Store
##

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="mxmlscores"
APP_DIR="/Users/Michele/Sites/mxmlscores"
CERT_DIR="$HOME/.nextcloud/certificates"
PRIVATE_KEY="$CERT_DIR/${APP_NAME}.key"
PUBLIC_CERT="$CERT_DIR/${APP_NAME}.crt"
SIGNATURE_FILE="$APP_DIR/appinfo/signature.json"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Nextcloud App Code Signing Tool      ║${NC}"
echo -e "${BLUE}║           ${APP_NAME}                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if keys exist
echo -e "${YELLOW}Step 1: Checking signing keys...${NC}"

if [ ! -f "$PRIVATE_KEY" ]; then
    echo -e "${RED}✗ Private key not found: $PRIVATE_KEY${NC}"
    echo ""
    echo "Generate keys with:"
    echo "  mkdir -p $CERT_DIR"
    echo "  openssl genrsa -out $PRIVATE_KEY 4096"
    echo "  openssl rsa -in $PRIVATE_KEY -pubout -out $PUBLIC_CERT"
    exit 1
fi

if [ ! -f "$PUBLIC_CERT" ]; then
    echo -e "${RED}✗ Public certificate not found: $PUBLIC_CERT${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Private key: $PRIVATE_KEY${NC}"
echo -e "${GREEN}✓ Public cert: $PUBLIC_CERT${NC}"

# Step 2: Build the app
echo -e "${YELLOW}Step 2: Building app...${NC}"
cd "$APP_DIR"

if [ -f "package.json" ]; then
    npm run build
    echo -e "${GREEN}✓ App built successfully${NC}"
else
    echo -e "${YELLOW}⚠ No package.json found, skipping build${NC}"
fi

# Step 3: Create file list for signing
echo -e "${YELLOW}Step 3: Creating file list for signing...${NC}"

# Remove old signature if exists
if [ -f "$SIGNATURE_FILE" ]; then
    rm "$SIGNATURE_FILE"
    echo "  → Removed old signature"
fi

# Create list of files to sign
# Exclude: .git, node_modules, tests, signatures, build artifacts
FILE_LIST=$(find . -type f \
    -not -path "./.git/*" \
    -not -path "./node_modules/*" \
    -not -path "./build_package/*" \
    -not -path "./dist/*" \
    -not -path "./.mxmlscores-testsprite/*" \
    -not -path "./testsprite_tests/*" \
    -not -path "*/signature.json" \
    -not -name ".DS_Store" \
    -not -name "*.log" \
    | sort)

FILE_COUNT=$(echo "$FILE_LIST" | wc -l | tr -d ' ')
echo -e "${GREEN}✓ Found $FILE_COUNT files to sign${NC}"

# Step 4: Generate signatures
echo -e "${YELLOW}Step 4: Generating signatures...${NC}"

# Create temporary file for hashes
TEMP_HASHES=$(mktemp)

echo "{" > "$TEMP_HASHES"
echo '  "hashes": {' >> "$TEMP_HASHES"

FIRST=true
while IFS= read -r file; do
    # Remove leading ./
    clean_file="${file#./}"

    # Calculate SHA512 hash
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        hash=$(openssl dgst -sha512 -binary "$file" | openssl base64 | tr -d '\n')
    else
        # Linux
        hash=$(sha512sum "$file" | cut -d' ' -f1 | xxd -r -p | base64 | tr -d '\n')
    fi

    # Add comma for all but first entry
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$TEMP_HASHES"
    fi

    # Add hash entry
    echo -n "    \"$clean_file\": \"$hash\"" >> "$TEMP_HASHES"
done <<< "$FILE_LIST"

echo "" >> "$TEMP_HASHES"
echo '  },' >> "$TEMP_HASHES"

# Step 5: Sign the hashes
echo -e "${YELLOW}Step 5: Creating signature...${NC}"

# Extract just the hashes section for signing
HASHES_ONLY=$(grep -A 999999 '"hashes"' "$TEMP_HASHES" | sed '$ d')

# Sign the hashes
SIGNATURE=$(echo -n "$HASHES_ONLY" | openssl dgst -sha512 -sign "$PRIVATE_KEY" | openssl base64 | tr -d '\n')

# Create final signature.json
cat "$TEMP_HASHES" > "$SIGNATURE_FILE"
echo "  \"signature\": \"$SIGNATURE\"," >> "$SIGNATURE_FILE"

# Add certificate
echo '  "certificate": "' >> "$SIGNATURE_FILE"
grep -v "BEGIN PUBLIC KEY" "$PUBLIC_CERT" | grep -v "END PUBLIC KEY" | tr -d '\n' >> "$SIGNATURE_FILE"
echo '"' >> "$SIGNATURE_FILE"
echo "}" >> "$SIGNATURE_FILE"

# Clean up
rm "$TEMP_HASHES"

# Step 6: Verify signature file
echo -e "${YELLOW}Step 6: Verifying signature...${NC}"

if [ -f "$SIGNATURE_FILE" ]; then
    SIZE=$(wc -c < "$SIGNATURE_FILE" | tr -d ' ')
    echo -e "${GREEN}✓ Signature created: appinfo/signature.json (${SIZE} bytes)${NC}"

    # Show summary
    HASH_COUNT=$(grep -o "\".*\": \"" "$SIGNATURE_FILE" | wc -l | tr -d ' ')
    echo -e "${GREEN}✓ Signed $HASH_COUNT file hashes${NC}"
else
    echo -e "${RED}✗ Failed to create signature file${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       App signed successfully! ✓          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Test the signed app in a Nextcloud instance"
echo -e "  2. Create distributable package: ${BLUE}./package-app.sh${NC}"
echo -e "  3. Submit to Nextcloud App Store"
echo ""
echo -e "${YELLOW}⚠ Important:${NC}"
echo -e "  • Keep your private key (${PRIVATE_KEY}) secure!"
echo -e "  • Never commit signature.json to git"
echo -e "  • Resign after any code changes"
echo ""
