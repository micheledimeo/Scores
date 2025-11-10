# Utility Scripts and Documentation

This branch (`utils`) contains development and deployment utilities for the mxmlscores Nextcloud app.

## 📌 Important

**These files are NOT included in the main branch** to keep the public repository clean and focused on the app code.

## 📂 Branch Organization

All utilities are organized in dedicated folders:

- **`scripts/`** - Shell scripts for deployment, packaging, and maintenance
- **`docs/`** - Extended documentation and guides

## 📜 Available Scripts (in scripts/ folder)

### Deployment Scripts

- **`scripts/deploy-production.sh`** - Deploy the app to production server
  ```bash
  ./scripts/deploy-production.sh
  ```

- **`scripts/deploy-and-test.sh`** - Deploy and run tests
  ```bash
  ./scripts/deploy-and-test.sh
  ```

### Packaging Scripts

- **`scripts/package-app.sh`** - Create distributable tar.gz package
  ```bash
  ./scripts/package-app.sh
  # Creates: project-files/dist/mxmlscores-[version].tar.gz
  ```

- **`scripts/sign-app.sh`** - Sign app for Nextcloud App Store
  ```bash
  ./scripts/sign-app.sh
  ```

### Repository Management

- **`scripts/update-repo-urls.sh`** - Update repository URLs in info.xml
  ```bash
  ./scripts/update-repo-urls.sh [github-username] [author-email]
  ```

- **`scripts/backup.sh`** - Backup utility
  ```bash
  ./scripts/backup.sh
  ```

## 📚 Documentation Files (in docs/ folder)

- **`docs/DEPLOY_CHECKLIST.md`** - Deployment checklist
- **`docs/WORKFLOW.md`** - Development workflow
- **`docs/GITHUB_SETUP.md`** - GitHub setup guide
- **`docs/INSTALL.md`** - Installation instructions
- **`docs/CSR_SUBMISSION_GUIDE.md`** - Certificate Signing Request guide
- **`docs/NEXTCLOUD_APPSTORE_SUBMISSION.md`** - App Store submission data

## 🔄 How to Use This Branch

### Get utility scripts when needed

```bash
# From main branch, copy specific scripts/docs
git checkout utils -- scripts/package-app.sh
git checkout utils -- docs/DEPLOY_CHECKLIST.md

# Use the script
./scripts/package-app.sh

# The files are gitignored in main, so they won't be committed
```

### Update scripts

```bash
# Switch to utils branch
git checkout utils

# Edit scripts (now in organized folders)
vim scripts/deploy-production.sh
vim docs/WORKFLOW.md

# Commit changes
git add scripts/ docs/
git commit -m "Update deployment utilities"
git push origin utils

# Return to main
git checkout main
```

### Sync all utils to local working directory

```bash
# From main branch, get all utils without committing them
git checkout utils -- scripts/
git checkout utils -- docs/

# Use them (they're gitignored so won't be committed to main)
```

## 🌿 Branch Structure

- **`main`** - Clean public repository with app code only
- **`utils`** - Development utilities and extended documentation (this branch)

## ⚙️ .gitignore Configuration

- In `main` branch: Utility scripts are ignored
- In `utils` branch: Utility scripts are tracked and versioned

This allows you to:
- Keep utility scripts under version control
- Prevent them from appearing in the public repository
- Easy access when needed without cluttering the main branch
