# Contributing to Scores for Nextcloud

Thank you for your interest in contributing to the Scores app! This document provides guidelines and instructions for contributing.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Code Style](#code-style)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project follows the Nextcloud Code of Conduct. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites
- Nextcloud 28.x - 33.x
- PHP 8.1 or later (8.2+ recommended)
- Node.js 20.x or later
- npm 10.x or later
- Git

### Finding Issues to Work On

1. Check the [Issues page](https://github.com/micheledimeo/mxmlscores/issues)
2. Look for issues labeled:
   - `good first issue` - Great for newcomers
   - `help wanted` - We need assistance
   - `bug` - Bug fixes needed
   - `enhancement` - New features or improvements

3. Comment on the issue to let others know you're working on it

## Development Setup

### 1. Fork and Clone
```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/mxmlscores.git
cd mxmlscores

# Add upstream remote
git remote add upstream https://github.com/micheledimeo/mxmlscores.git
```

### 2. Install Dependencies
```bash
# Install Node.js dependencies
npm install
```

### 3. Set Up Nextcloud Development Environment
```bash
# Link to your Nextcloud apps directory
ln -s /path/to/mxmlscores /path/to/nextcloud/apps/mxmlscores

# Enable the app
cd /path/to/nextcloud
sudo -u www-data php occ app:enable mxmlscores
```

### 4. Start Development Server
```bash
# In the mxmlscores directory
npm run dev
```

This starts Vite in watch mode. Changes to Vue/JS/CSS files will be rebuilt automatically.

## Making Changes

### 1. Create a Branch
```bash
# Update your fork
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
# or for bug fixes
git checkout -b fix/issue-description
```

### 2. Make Your Changes

#### Frontend (Vue.js)
- Components are in `src/components/`
- Main app: `src/components/App.vue`
- Music viewer: `src/components/MusicViewer.vue`
- Utilities: `src/utils/`

#### Backend (PHP)
- Controllers are in `lib/Controller/`
- API endpoints: `lib/Controller/ApiController.php`
- Settings: `lib/Controller/SettingsController.php`
- Page rendering: `lib/Controller/PageController.php`

#### Styles
- Global styles: `src/css/main.scss`
- Component styles: In `<style>` section of `.vue` files

### 3. Follow Code Style

#### JavaScript/Vue
- Use ES6+ syntax
- Composition API for Vue components
- 2-space or tab indentation (follow existing style)
- Clear, descriptive variable names
- Add JSDoc comments for complex functions

```javascript
/**
 * Load music files from the Nextcloud API
 * @returns {Promise<void>}
 */
const loadFiles = async () => {
  // Implementation
}
```

#### PHP
- Follow PSR-12 coding standards
- Use type declarations
- DocBlocks for all methods

```php
/**
 * Get file content by ID
 * @param int $fileId File ID
 * @return DataResponse
 */
public function getFile(int $fileId): DataResponse {
    // Implementation
}
```

#### CSS/SCSS
- Follow Nextcloud design guidelines
- Use CSS custom properties for colors
- Mobile-first responsive design
- Clear, semantic class names

### 4. Test Your Changes

#### Manual Testing
1. Build the app: `npm run build`
2. Test in Nextcloud:
   - Upload test MusicXML files
   - Test playback controls
   - Test search and navigation
   - Test admin settings
3. Test on different browsers:
   - Chrome/Edge
   - Firefox
   - Safari (including iOS)
4. Check browser console for errors

#### Automated Testing (if available)
```bash
npm test
```

#### Build Verification
```bash
# Ensure build succeeds without errors
npm run build

# Check for linting issues
npm run lint
npm run stylelint
```

## Submitting Changes

### 1. Commit Your Changes
```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: add tempo control to playback controls"
```

#### Commit Message Format
Use conventional commits format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add instrument mixer with solo/mute controls
fix: correct iOS Safari audio playback issue
docs: update README with keyboard shortcuts
style: format ApiController.php with PSR-12
refactor: extract playback logic to MixerInstrumentPlayer
perf: optimize folder tree rendering
test: add iOS audio diagnostic tests
chore: update dependencies to latest versions
```

### 2. Push to Your Fork
```bash
git push origin feature/your-feature-name
```

### 3. Create a Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Select your branch
4. Fill out the PR template:
   - Description of changes
   - Related issue(s)
   - Type of change
   - Testing performed
   - Screenshots (if applicable)
5. Submit the PR

### 4. Code Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Update your PR by pushing new commits to your branch
- Once approved, your PR will be merged

## Code Style

### Vue.js Components
```vue
<template>
  <div class="component-name">
    <!-- Template -->
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'ComponentName',
  setup() {
    // Reactive state
    const state = ref(initialValue)

    // Computed properties
    const computed Prop = computed(() => {
      // Computation
    })

    // Methods
    const methodName = () => {
      // Implementation
    }

    // Lifecycle
    onMounted(() => {
      // Initialization
    })

    // Expose to template
    return {
      state,
      computedProp,
      methodName
    }
  }
}
</script>

<style scoped>
.component-name {
  /* Styles */
}
</style>
```

### PHP Controllers
```php
<?php
declare(strict_types=1);

namespace OCA\Scores\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\DataResponse;

class ExampleController extends Controller {
    private SomeService $service;

    public function __construct(
        string $appName,
        IRequest $request,
        SomeService $service
    ) {
        parent::__construct($appName, $request);
        $this->service = $service;
    }

    /**
     * @NoAdminRequired
     */
    public function doSomething(int $id): DataResponse {
        try {
            $result = $this->service->process($id);
            return new DataResponse($result);
        } catch (\Exception $e) {
            return new DataResponse(
                ['error' => $e->getMessage()],
                Http::STATUS_INTERNAL_SERVER_ERROR
            );
        }
    }
}
```

## Testing

### Manual Testing Checklist
- [ ] Upload various MusicXML file formats (.xml, .mxl, .musicxml)
- [ ] Test playback (play, pause, stop, loop)
- [ ] Test tempo and volume controls
- [ ] Test instrument mixer (if multi-channel file)
- [ ] Test keyboard shortcuts (Space, arrows, +/-)
- [ ] Test search functionality
- [ ] Test folder navigation
- [ ] Test on desktop browsers (Chrome, Firefox, Safari)
- [ ] Test on mobile browsers (iOS Safari, Android Chrome)
- [ ] Test admin settings (folder configuration)
- [ ] Check browser console for errors
- [ ] Verify responsive layout at different screen sizes

### Browser Compatibility
- Chrome/Edge (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions, including iOS 17+)

## Documentation

### Update Documentation When:
- Adding new features → Update README.md and CHANGELOG.md
- Changing configuration → Update README.md
- Fixing bugs → Update CHANGELOG.md
- Changing scripts → Update project-files/scripts/README.md
- Changing API → Add/update PHPDoc and JSDoc

### Documentation Files
- `README.md` - Main project documentation
- `CHANGELOG.md` - Version history and changes
- `project-files/scripts/README.md` - Scripts documentation
- `CONTRIBUTING.md` - This file
- Inline code comments - For complex logic

## Release Process

Maintainers handle releases:
1. Update version in `appinfo/info.xml` and `package.json`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag vX.Y.Z`
4. Push tag: `git push origin vX.Y.Z`
5. GitHub Actions builds and creates release
6. Submit signed package to Nextcloud App Store

## Questions?

- Open an issue for questions about contributing
- Check existing issues and documentation first
- Be specific and provide context

## Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort! 🎵
