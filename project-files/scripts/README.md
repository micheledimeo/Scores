# Deployment & Build Scripts

This directory contains scripts for building, deploying, packaging, and managing the scores Nextcloud app.

## Scripts Overview

### 📦 package-app.sh
**Purpose**: Creates a distributable tar.gz package for installation on other Nextcloud instances.

**What it does**:
1. Builds the app using `npm run build`
2. Creates a clean build directory excluding development files
3. Copies only production-necessary files:
   - Built JavaScript and CSS (`js/`, `css/`)
   - PHP backend (`lib/`)
   - App metadata (`appinfo/`)
   - Templates (`templates/`)
   - Icons (`img/`)
   - Public test files (if present)
   - Documentation (`README.md`, `LICENSE`, `CHANGELOG.md`, `INSTALL.md`)
4. Creates tar.gz archive with version number from `info.xml`
5. Generates MD5 checksum file
6. Outputs package to `project-files/dist/`

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/package-app.sh
```

**Output**:
- `project-files/dist/scores-X.Y.Z.tar.gz` - Distributable package
- `project-files/dist/scores-X.Y.Z.tar.gz.md5` - Checksum file

**Installation on target server**:
```bash
# Transfer package to target Nextcloud server
scp scores-X.Y.Z.tar.gz user@server:/path/to/nextcloud/apps/

# On server
cd /path/to/nextcloud/apps
tar -xzf scores-X.Y.Z.tar.gz
chown -R www-data:www-data scores
# Enable from Nextcloud admin panel or:
sudo -u www-data php occ app:enable scores
```

---

### 🚀 deploy-production.sh
**Purpose**: Builds and deploys the app to production server via SSH.

**What it does**:
1. Builds app locally with `npm run build`
2. Creates necessary directories on remote server
3. Transfers built files via tar over SSH:
   - JavaScript (`js/`)
   - CSS (`css/`)
   - App metadata (`appinfo/`)
   - Templates (`templates/`)
   - PHP controllers (`lib/Controller/`)
   - App icons (`img/`)
   - Test sample files (`public/test-scores/`)
4. Sets correct ownership and permissions on server

**Configuration**:
```bash
APP_NAME="scores"
LOCAL_DIR="/Users/Michele/Sites/scores"
REMOTE_USER="root"
REMOTE_HOST="ottoniascoppio"  # Uses SSH config
REMOTE_DIR="/home/ottoniascoppio/domains/cloud.ottoniascoppio.org/public_html/apps/scores"
```

**Prerequisites**:
- SSH key authentication configured for remote host
- SSH config entry for host (or use IP address)
- Remote directory writable by SSH user

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/deploy-production.sh
```

**SSH Config** (`~/.ssh/config`):
```
Host ottoniascoppio
    HostName your-server-ip-or-domain
    User root
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
```

**Testing deployed app**:
- App URL: `https://cloud.ottoniascoppio.org/index.php/apps/scores`
- Test mode: `https://cloud.ottoniascoppio.org/index.php/apps/scores/?testSample=1`

---

### ✍️ sign-app.sh
**Purpose**: Code-sign the app for Nextcloud App Store submission.

**What it does**:
1. Checks for required signing keys in `~/.nextcloud/certificates/`
2. Builds the app
3. Creates list of files to sign (excludes git, node_modules, etc.)
4. Generates SHA512 hashes for each file
5. Signs the hash list with private key
6. Creates `appinfo/signature.json` with:
   - File hashes
   - Cryptographic signature
   - Public certificate

**Prerequisites - Generate keys first**:
```bash
# Create certificate directory
mkdir -p ~/.nextcloud/certificates

# Generate private key (4096-bit RSA)
openssl genrsa -out ~/.nextcloud/certificates/scores.key 4096

# Extract public certificate
openssl rsa -in ~/.nextcloud/certificates/scores.key -pubout \
    -out ~/.nextcloud/certificates/scores.crt
```

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/sign-app.sh
```

**Output**:
- `appinfo/signature.json` - Code signature file

**IMPORTANT**:
- ⚠️ **Never commit** `signature.json` to git (already in `.gitignore`)
- ⚠️ **Keep private key secure** - backup to encrypted storage
- ⚠️ **Resign after any code change** - signature validates file integrity
- ⚠️ **Do not share private key** - used to verify your identity

**Workflow for App Store submission**:
1. Make code changes
2. Update version in `appinfo/info.xml`
3. Build: `npm run build`
4. Sign: `./project-files/scripts/sign-app.sh`
5. Package: `./project-files/scripts/package-app.sh`
6. Submit package to Nextcloud App Store

---

### 💾 backup.sh
**Purpose**: Creates timestamped backups with automatic retention management.

**What it does**:
1. Creates timestamped tar.gz backup of source code
2. Includes:
   - Source code (`src/`)
   - Built files (`js/`, `css/`)
   - App metadata (`appinfo/`)
   - Templates (`templates/`)
   - PHP backend (`lib/`)
   - Configuration files (`package.json`, `vite.config.js`)
   - Deployment script
3. Excludes:
   - `node_modules/`
   - `.git/`
   - Log files
   - `.DS_Store`
4. Manages retention: keeps last 30 backups, auto-deletes older ones
5. Saves to `project-files/backups/`

**Configuration**:
```bash
APP_DIR="/Users/Michele/Sites/scores"
BACKUP_DIR="${APP_DIR}/project-files/backups"
MAX_BACKUPS=30  # Keep last 30 backups
```

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/backup.sh
```

**Output**:
- `project-files/backups/scores_backup_YYYYMMDD_HHMMSS.tar.gz`

**Restore from backup**:
```bash
# View backup contents
tar -tzf project-files/backups/scores_backup_20251111_142922.tar.gz

# Extract backup
cd /Users/Michele/Sites/
tar -xzf scores/project-files/backups/scores_backup_20251111_142922.tar.gz

# Or extract to different location
mkdir restore-test
tar -xzf scores/project-files/backups/scores_backup_20251111_142922.tar.gz -C restore-test
```

**Automated backups** (optional - using cron):
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /Users/Michele/Sites/scores/project-files/scripts/backup.sh >> /Users/Michele/Sites/scores/project-files/backups/backup.log 2>&1
```

---

### 🧪 deploy-and-test.sh
**Purpose**: Deploy to production and run automated tests.

**What it does**:
1. Runs `deploy-production.sh` to deploy latest code
2. Waits for deployment to complete
3. Executes TestSprite test suite
4. Reports test results

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/deploy-and-test.sh
```

---

### 🔗 update-repo-urls.sh
**Purpose**: Update repository URLs across configuration files.

**What it does**:
- Updates GitHub repository URLs in:
  - `package.json`
  - `appinfo/info.xml`
  - Documentation files
- Useful when forking or changing repository location

**Usage**:
```bash
cd /Users/Michele/Sites/scores
./project-files/scripts/update-repo-urls.sh
```

---

## Common Workflows

### Development to Production Deployment
```bash
# 1. Make changes to source code
# 2. Test locally
npm run dev

# 3. Build for production
npm run build

# 4. Deploy to production server
./project-files/scripts/deploy-production.sh

# 5. Test deployed version
open https://cloud.ottoniascoppio.org/index.php/apps/scores
```

### Creating a Release Package
```bash
# 1. Update version in appinfo/info.xml
# 2. Update CHANGELOG.md
# 3. Commit changes
git add appinfo/info.xml CHANGELOG.md
git commit -m "Bump version to X.Y.Z"

# 4. Build and package
npm run build
./project-files/scripts/package-app.sh

# 5. Sign app (for App Store submission)
./project-files/scripts/sign-app.sh

# 6. Package signed version
./project-files/scripts/package-app.sh

# 7. Create git tag
git tag vX.Y.Z
git push origin vX.Y.Z

# 8. Create GitHub release with package
# Upload: project-files/dist/scores-X.Y.Z.tar.gz
```

### Before Major Changes - Create Backup
```bash
# Create backup before risky changes
./project-files/scripts/backup.sh

# Make changes...

# If needed, restore from backup
tar -xzf project-files/backups/scores_backup_YYYYMMDD_HHMMSS.tar.gz
```

---

## File Permissions

All scripts should be executable:
```bash
chmod +x project-files/scripts/*.sh
```

If permission denied:
```bash
cd /Users/Michele/Sites/scores
chmod +x project-files/scripts/deploy-production.sh
chmod +x project-files/scripts/package-app.sh
chmod +x project-files/scripts/sign-app.sh
chmod +x project-files/scripts/backup.sh
chmod +x project-files/scripts/deploy-and-test.sh
chmod +x project-files/scripts/update-repo-urls.sh
```

---

## Troubleshooting

### deploy-production.sh: SSH connection failed
```bash
# Test SSH connection
ssh root@ottoniascoppio

# Check SSH config
cat ~/.ssh/config

# Add host to SSH config if needed
nano ~/.ssh/config
```

### package-app.sh: Build failed
```bash
# Clean and rebuild
rm -rf node_modules js css
npm install
npm run build
```

### sign-app.sh: Keys not found
```bash
# Check if keys exist
ls -la ~/.nextcloud/certificates/

# Generate keys if missing (see sign-app.sh section above)
```

### backup.sh: Permission denied
```bash
# Check backup directory exists
mkdir -p project-files/backups

# Check permissions
ls -la project-files/
```

---

## Directory Structure

```
project-files/
├── scripts/
│   ├── README.md              # This file
│   ├── deploy-production.sh   # Deploy to production server
│   ├── package-app.sh         # Create distribution package
│   ├── sign-app.sh            # Code-sign for App Store
│   ├── backup.sh              # Create timestamped backups
│   ├── deploy-and-test.sh     # Deploy and run tests
│   └── update-repo-urls.sh    # Update repository URLs
├── dist/                      # Distribution packages
│   ├── scores-X.Y.Z.tar.gz
│   └── scores-X.Y.Z.tar.gz.md5
├── backups/                   # Automated backups
│   └── scores_backup_YYYYMMDD_HHMMSS.tar.gz
└── testsprite/                # TestSprite test configuration
```

---

## Security Notes

1. **Private Keys**: Never commit signing keys to git
2. **SSH Keys**: Use SSH key authentication, not passwords
3. **Signatures**: Always resign after code changes
4. **Backups**: Store backups securely, consider encryption for sensitive data
5. **Permissions**: Review file permissions before deployment
6. **Server Access**: Limit SSH access to trusted IPs if possible

---

## Version History

- **v0.9.6** - Added comprehensive README documentation
- **v0.9.5** - Added TestSprite integration in deploy-and-test.sh
- **v0.9.4** - Enhanced backup.sh with retention management
- **v0.9.3** - Added sign-app.sh for App Store submission
- **v0.9.2** - Initial script collection

---

## Support

For issues with these scripts:
1. Check script permissions: `ls -la project-files/scripts/`
2. Verify paths in script configuration sections
3. Check logs for error messages
4. Consult main README.md for app-specific issues
