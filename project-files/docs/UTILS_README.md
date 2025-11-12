# Utility Scripts and Documentation

This branch (`utils`) contains development and deployment utilities for the scores Nextcloud app.

## 📌 Important

**These files are NOT included in the main branch** to keep the public repository clean and focused on the app code.

## 📂 Project Organization

All development files are in the `project-files/` directory:

- **`project-files/scripts/`** - Shell scripts for deployment, packaging, and maintenance
- **`project-files/docs/`** - Extended documentation and guides
- **`project-files/testsprite/`** - Test suite
- **`project-files/dist/`** - Build artifacts
- **`project-files/backups/`** - App backups
- **`project-files/screenshots/`** - App Store screenshots

## 📜 Available Scripts (in project-files/scripts/)

### Deployment Scripts

- **`project-files/scripts/deploy-production.sh`** - Deploy the app to production server
  ```bash
  ./project-files/scripts/deploy-production.sh
  ```

- **`project-files/scripts/deploy-and-test.sh`** - Deploy and run tests
  ```bash
  ./project-files/scripts/deploy-and-test.sh
  ```

### Packaging Scripts

- **`project-files/scripts/package-app.sh`** - Create distributable tar.gz package
  ```bash
  ./project-files/scripts/package-app.sh
  # Creates: project-files/dist/scores-[version].tar.gz
  ```

- **`project-files/scripts/sign-app.sh`** - Sign app for Nextcloud App Store
  ```bash
  ./project-files/scripts/sign-app.sh
  ```

### Repository Management

- **`project-files/scripts/update-repo-urls.sh`** - Update repository URLs in info.xml
  ```bash
  ./project-files/scripts/update-repo-urls.sh [github-username] [author-email]
  ```

- **`project-files/scripts/backup.sh`** - Backup utility
  ```bash
  ./project-files/scripts/backup.sh
  ```

## 📚 Documentation Files (in project-files/docs/)

- **`project-files/docs/DEPLOY_CHECKLIST.md`** - Deployment checklist
- **`project-files/docs/WORKFLOW.md`** - Development workflow
- **`project-files/docs/GITHUB_SETUP.md`** - GitHub setup guide
- **`project-files/docs/INSTALL.md`** - Installation instructions
- **`project-files/docs/CSR_SUBMISSION_GUIDE.md`** - Certificate Signing Request guide
- **`project-files/docs/NEXTCLOUD_APPSTORE_SUBMISSION.md`** - App Store submission data

## 🔄 How to Use This Branch

### Get utility scripts when needed

```bash
# From main branch, copy entire project-files directory
git checkout utils -- project-files/

# Use the scripts
./project-files/scripts/package-app.sh
./project-files/scripts/deploy-production.sh

# The project-files/ directory is gitignored in main, so won't be committed
```

### Update scripts

```bash
# Switch to utils branch
git checkout utils

# Edit files in project-files
vim project-files/scripts/deploy-production.sh
vim project-files/docs/WORKFLOW.md

# Commit changes
git add project-files/
git commit -m "Update deployment utilities"
git push origin utils

# Return to main
git checkout main
```

### Sync all project files to local working directory

```bash
# From main branch, get all project files without committing them
git checkout utils -- project-files/

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
