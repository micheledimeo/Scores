# Utility Scripts and Documentation

This branch (`utils`) contains development and deployment utilities for the mxmlscores Nextcloud app.

## 📌 Important

**These files are NOT included in the main branch** to keep the public repository clean and focused on the app code.

## 📜 Available Scripts

### Deployment Scripts

- **`deploy-production.sh`** - Deploy the app to production server
  ```bash
  ./deploy-production.sh
  ```

- **`deploy-and-test.sh`** - Deploy and run tests
  ```bash
  ./deploy-and-test.sh
  ```

### Packaging Scripts

- **`package-app.sh`** - Create distributable tar.gz package
  ```bash
  ./package-app.sh
  # Creates: dist/mxmlscores-[version].tar.gz
  ```

### Repository Management

- **`update-repo-urls.sh`** - Update repository URLs in info.xml
  ```bash
  ./update-repo-urls.sh [github-username] [author-email]
  ```

- **`backup.sh`** - Backup utility
  ```bash
  ./backup.sh
  ```

## 📚 Documentation Files

- **`DEPLOY_CHECKLIST.md`** - Deployment checklist
- **`WORKFLOW.md`** - Development workflow
- **`GITHUB_SETUP.md`** - GitHub setup guide
- **`INSTALL.md`** - Installation instructions

## 🔄 How to Use This Branch

### Get utility scripts when needed

```bash
# From main branch, copy a specific script
git checkout utils -- package-app.sh

# Use the script
./package-app.sh

# The file is gitignored in main, so it won't be committed
```

### Update scripts

```bash
# Switch to utils branch
git checkout utils

# Edit scripts
vim deploy-production.sh

# Commit changes
git add deploy-production.sh
git commit -m "Update deployment script"
git push origin utils

# Return to main
git checkout main
```

### Sync all utils to local working directory

```bash
# From main branch, get all utils without committing them
git checkout utils -- package-app.sh deploy-production.sh backup.sh
git checkout utils -- DEPLOY_CHECKLIST.md WORKFLOW.md GITHUB_SETUP.md INSTALL.md

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
