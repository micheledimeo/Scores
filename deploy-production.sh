#!/bin/bash
# Deploy script for Scores app - PRODUCTION SERVER
# Complete deployment with all app components
# Updated: 2025-11-10
# Location: mxmlscores/deploy-production.sh

set -e  # Exit on any error

REMOTE_HOST="ottoniascoppio"
REMOTE_APP_PATH="/home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html/apps/mxmlscores"
# Script is now in app folder, use current directory
LOCAL_PATH="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Scores App - PRODUCTION Deployment"
echo "======================================"

# Check if files exist
if [ ! -f "$LOCAL_PATH/js/mxml-scores-main.js" ]; then
    echo "❌ Error: js/mxml-scores-main.js not found. Run 'npm run build' first."
    exit 1
fi

if [ ! -f "$LOCAL_PATH/css/main.css" ]; then
    echo "❌ Error: css/main.css not found. Run 'npm run build' first."
    exit 1
fi

if [ ! -f "$LOCAL_PATH/src/init-app.js" ]; then
    echo "❌ Error: src/init-app.js not found."
    exit 1
fi

echo ""
echo "📦 Step 1: Verifying compiled files..."
ls -lh "$LOCAL_PATH/js/mxml-scores-main.js" | awk '{printf "   JS Main: %s\n", $5}'
ls -lh "$LOCAL_PATH/css/main.css" | awk '{printf "   CSS:     %s\n", $5}'
ls -lh "$LOCAL_PATH/src/init-app.js" | awk '{printf "   Init JS: %s\n", $5}'
echo "✅ Compiled files verified"

echo ""
echo "📋 Step 2: Preparing init-app.js..."
cp "$LOCAL_PATH/src/init-app.js" "$LOCAL_PATH/js/"
echo "✅ init-app.js copied to js/"

echo ""
echo "🧹 Step 3: Creating directory structure..."
ssh "$REMOTE_HOST" "mkdir -p $REMOTE_APP_PATH/{appinfo,css,img,js,lib,templates}"
echo "✅ Directory structure created"

echo ""
echo "🗑️  Step 4: Cleaning old files on server..."
ssh "$REMOTE_HOST" "rm -f $REMOTE_APP_PATH/js/mxmlscores-main.js 2>/dev/null"
ssh "$REMOTE_HOST" "rm -f $REMOTE_APP_PATH/appinfo/app.php 2>/dev/null"
echo "✅ Old files removed"

echo ""
echo "⬆️  Step 5: Uploading JavaScript..."
scp -q "$LOCAL_PATH/js/mxml-scores-main.js" "$REMOTE_HOST:$REMOTE_APP_PATH/js/"
scp -q "$LOCAL_PATH/js/init-app.js" "$REMOTE_HOST:$REMOTE_APP_PATH/js/"
echo "✅ JavaScript uploaded"

echo ""
echo "⬆️  Step 6: Uploading CSS..."
scp -q "$LOCAL_PATH/css/main.css" "$REMOTE_HOST:$REMOTE_APP_PATH/css/"
echo "✅ CSS uploaded"

echo ""
echo "⬆️  Step 7: Uploading PHP backend..."
scp -qr "$LOCAL_PATH/lib" "$REMOTE_HOST:$REMOTE_APP_PATH/"
echo "✅ PHP backend uploaded"

echo ""
echo "⬆️  Step 8: Uploading appinfo..."
scp -q "$LOCAL_PATH/appinfo/info.xml" "$REMOTE_HOST:$REMOTE_APP_PATH/appinfo/"
scp -q "$LOCAL_PATH/appinfo/routes.php" "$REMOTE_HOST:$REMOTE_APP_PATH/appinfo/"
echo "✅ Appinfo uploaded"

echo ""
echo "⬆️  Step 9: Uploading templates..."
scp -qr "$LOCAL_PATH/templates/"* "$REMOTE_HOST:$REMOTE_APP_PATH/templates/"
echo "✅ Templates uploaded"

echo ""
echo "⬆️  Step 10: Uploading app icon..."
scp -q "$LOCAL_PATH/img/app.svg" "$REMOTE_HOST:$REMOTE_APP_PATH/img/"
echo "✅ App icon uploaded"

echo ""
echo "🔍 Step 11: Verifying deployment..."
ssh "$REMOTE_HOST" "ls -lh $REMOTE_APP_PATH/css/main.css $REMOTE_APP_PATH/js/mxml-scores-main.js $REMOTE_APP_PATH/js/init-app.js 2>/dev/null | tail -3"

echo ""
echo "🔒 Step 12: Setting permissions..."
ssh "$REMOTE_HOST" "sudo chown -R ottoniascoppio:ottoniascoppio $REMOTE_APP_PATH && chmod -R 755 $REMOTE_APP_PATH"
echo "✅ Permissions set"

echo ""
echo "🔄 Step 13: Reloading app..."
ssh "$REMOTE_HOST" "cd /home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html && php occ app:disable mxmlscores" > /dev/null
ssh "$REMOTE_HOST" "cd /home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html && php occ app:enable mxmlscores"
echo "✅ App reloaded"

echo ""
echo "🧹 Step 14: Clearing cache..."
ssh "$REMOTE_HOST" "redis-cli FLUSHALL" > /dev/null 2>&1
echo "✅ Cache cleared"

echo ""
echo "🔍 Step 15: Final verification..."
APP_STATUS=$(ssh "$REMOTE_HOST" "cd /home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html && php occ app:list | grep 'mxmlscores:' || echo 'NOT_FOUND'")
if [[ "$APP_STATUS" == *"NOT_FOUND"* ]]; then
    echo "❌ App not found in enabled apps list!"
    exit 1
fi
echo "   $APP_STATUS"
echo "✅ App verified and enabled"

echo ""
echo "✨ Deployment completed successfully!"
echo ""
echo "📋 Deployed to: cloud.ottoniascoppio.org"
echo "   ✅ mxml-scores-main.js (JavaScript bundle)"
echo "   ✅ init-app.js (App initialization)"
echo "   ✅ main.css (Styles)"
echo "   ✅ PHP controllers (lib/)"
echo "   ✅ App metadata (info.xml, routes.php)"
echo "   ✅ Templates (main.php, public.php)"
echo "   ✅ App icon (app.svg)"
echo ""
echo "🔄 Next steps:"
echo "   1. Hard refresh browser: Cmd+Shift+R"
echo "   2. Check browser console"
echo "   3. Test app at: https://cloud.ottoniascoppio.org"
echo ""
