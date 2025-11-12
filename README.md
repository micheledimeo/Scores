# Scores for Nextcloud

![App Name](https://img.shields.io/badge/App%20Name-Scores-blue?style=for-the-badge)
![App ID](https://img.shields.io/badge/App%20ID-scores-lightgrey?style=flat-square)
![Version](https://img.shields.io/badge/version-0.9.6-green?style=flat-square)
![License](https://img.shields.io/badge/license-AGPL--3.0-orange?style=flat-square)

Display, play, and manage MusicXML files directly in Nextcloud using OpenSheetMusicDisplay.

## Features

- 🎼 **Sheet Music Display**: Render MusicXML, MusicXML compressed (.mxl), and other music notation formats
- ▶️ **Advanced Playback Controls**: Play, pause, stop, and loop with real-time cursor tracking
- 🎚️ **Instrument Mixer**: Individual volume control for each instrument/channel with solo/mute capabilities
- 🎵 **Tempo & Volume Control**: Precise BPM adjustment (40-240) and master volume with numeric inputs
- 📊 **Progress Tracking**: Visual progress bar with current time and measure indicators
- ⌨️ **Keyboard Shortcuts**: Space (play/pause), arrows (navigate measures), +/- (zoom)
- 🔍 **Smart Search**: Real-time search with match counter across all scores and folders
- 📁 **Folder Navigation**: Organized folder tree with expandable/collapsible folders and file counts
- 📝 **Smart File Display**: Automatic left truncation for files in folders to show instrument names
- 🌍 **Internationalization**: Full i18n support with translation system for settings and UI
- 🎨 **Custom Icons**: Material Design icons integration (library_music app icon)
- 📱 **Responsive Design**: Adaptive layout with collapsible sidebar and optimized spacing
- 🔄 **Files App Integration**: Upload and share scores using Nextcloud Files app
- 🎯 **Admin Settings**: Configure multiple scores folder paths for all users with folder browser

## Supported Formats

- MusicXML (.xml, .musicxml, .mxml)
- MusicXML Compressed (.mxl)
- MEI (Music Encoding Initiative)
- Guitar Pro files (.gp, .gp3, .gp4, .gp5, .gpx)

## Compatibility

- **Nextcloud**: 28.x - 33.x (tested on 32.0.1)
- **PHP**: 8.1 - 8.4 (tested on 8.2)
- **Node.js**: 20.x or later
- **npm**: 10.x or later
- **Browsers**: Chrome, Firefox, Safari (including iOS/iPadOS 17.0+)

## Recent Improvements

### v0.9.6 - Score Folders & Configuration (2025-11-11)
- **Critical Bug Fix**: Files in custom Score Folders now display correctly
- **Streamlined UI**: Direct folder addition from Browse dialog
- **Smart Save Button**: Only enabled when changes are detected
- **JSON Configuration**: Modern configuration storage with CSV fallback
- **Distribution Tools**: Complete packaging and backup scripts

### v0.9.5 - iOS Audio Support (2025-11-10)
- **iOS/iPadOS Playback**: Full audio support for iOS Safari 17.0+
- **Audio Lifecycle**: Background/foreground transition handling
- **Testing Suite**: TestSprite-based iOS audio diagnostic tests
- **Search Counter**: Aligned with folder counter styling

### v0.9.4 - UI/UX Polish (2025-11-09)
- **Smart File Truncation**: Left truncation (max 30 chars) to show instrument names
- **File Count Badges**: Folders display total file count including subfolders
- **Material Design Icons**: Folder icons with proper spacing
- **Welcome Screen**: Quick Tips for keyboard shortcuts
- **CSS Improvements**: Fixed folder expansion and counter positioning

### v0.9.3 - Internationalization (2025-11-09)
- **Full i18n Support**: Translatable strings for all settings
- **Folder Browser**: Interactive navigation for path selection
- **Security**: Path traversal prevention

## Installation

### Prerequisites

- Nextcloud 28.x - 33.x
- PHP 8.1 or later (8.2+ recommended)
- Node.js 20 or later
- npm 10 or later

## Usage

### Basic Usage

1. Navigate to the **Scores** app in Nextcloud
2. Use the search box to find specific scores, or browse the folder tree
3. Click on a score file to open it
4. The sheet music will be displayed with playback controls

### Playback Controls

- **Play/Pause/Stop**: Control playback with buttons or press `Space`
- **Loop**: Enable loop mode to repeat playback continuously
- **Tempo (BPM)**: Adjust playback speed from 40 to 240 BPM using numeric input
- **Volume (VOL)**: Control master volume from 0 to 100 using numeric input
- **Mixer**: Toggle instrument mixer to solo/mute individual channels (when available)
- **Progress Bar**: Visual timeline showing current playback position with time and measure count

### Navigation

- **Keyboard Shortcuts**:
  - `Space`: Play / Pause
  - `←` `→`: Navigate between measures
  - `+` `-`: Zoom in / out
- **Responsive Layout**: Toggle sidebar visibility to maximize sheet music viewing area

### File Management

- **Upload**: Use the Nextcloud **Files** app to upload new MusicXML files
- **Sharing**: Use the Nextcloud **Files** app to share scores with other users
- **Search**: Real-time search filters both folder names and file names with match counter
- **Folder Organization**: Files are organized in expandable folders with file counts
- **Smart Display**: Files in folders show truncated names from left to display instrument information

### Admin Configuration

Administrators can configure the default scores folder paths:
1. Click on **Scores Settings** in the sidebar footer
2. Add one or more folder paths using the folder browser
3. Browse and select folders containing music scores
4. Remove unwanted paths using the delete button
5. Paths are relative to each user's home directory
6. Leave empty to scan all user files
7. Settings are stored in Nextcloud app config and applied to all users

## Project Structure

```
scores/
├── appinfo/
│   ├── info.xml          # App metadata
│   └── routes.php        # App routes
├── lib/
│   └── Controller/       # PHP controllers
│       ├── PageController.php
│       ├── ApiController.php
│       └── SettingsController.php
├── src/
│   ├── main.js           # Vue app entry point
│   ├── init-app.js       # App initialization
│   ├── components/       # Vue components
│   │   ├── App.vue       # Main app with navigation
│   │   └── MusicViewer.vue  # Score viewer with playback
│   ├── utils/            # Utility classes
│   │   └── MixerInstrumentPlayer.js  # Mixer implementation
│   └── css/
│       └── main.scss     # Global styles
├── templates/
│   ├── main.php          # Main template
│   └── public.php        # Public share template
├── js/                   # Build output
│   ├── mxml-scores-main.js
│   └── init-app.js
├── css/                  # Build output
│   └── main.css
├── package.json          # Node dependencies
├── vite.config.js        # Vite configuration
├── project-files/        # Development & distribution files (gitignored except docs)
│   ├── scripts/          # Build, deploy, packaging scripts
│   │   ├── package-app.sh
│   │   ├── deploy-production.sh
│   │   ├── sign-app.sh
│   │   ├── backup.sh
│   │   └── README.md     # Scripts documentation
│   ├── docs/             # Development documentation
│   │   ├── INSTALL.md
│   │   ├── WORKFLOW.md
│   │   └── NEXTCLOUD_APPSTORE_SUBMISSION.md
│   ├── screenshots/      # App screenshots for documentation
│   ├── dist/             # Built packages (gitignored)
│   ├── backups/          # Local backups (gitignored)
│   └── testsprite/       # Test configuration (gitignored)
├── .github/
│   ├── workflows/        # GitHub Actions CI/CD
│   │   ├── build.yml     # Build and test workflow
│   │   ├── release.yml   # Automated release creation
│   │   └── lint.yml      # Code linting
│   ├── CONTRIBUTING.md   # Contribution guidelines
│   └── dependabot.yml    # Dependency updates
└── README.md             # This file
```

## Technologies Used

- **OpenSheetMusicDisplay**: Music notation rendering
- **Vue 3**: Frontend framework
- **Vite**: Build tool
- **Nextcloud Vue Components**: UI components
- **PHP 8.1+**: Backend API

## Version History

### v0.9.6 (2025-11-11)
- **Score Folders Configuration Fix**: Critical bug fix for folder scanning
  - Fixed ApiController to read from correct configuration key ('scores_folders')
  - Files in newly added folders (e.g., MieScores) now appear correctly
  - Added backward compatibility for old CSV-based configuration
- **Improved Score Folders UI**: Streamlined folder management workflow
  - Browse → Confirm now directly adds folders (removed redundant Add button)
  - Save button intelligently disabled when no changes detected
  - Automatic file list refresh after saving new folder paths
- **Enhanced Configuration**: Multiple Score Folders with JSON storage
  - Support for multiple folder paths as JSON array
  - Interactive folder browser for easy path selection
  - Change detection for preventing unnecessary saves
- **Distribution**: Complete packaging and backup scripts in project-files/

### v0.9.5 (2025-11-10)
- **iOS/iPadOS Audio Support**: Fixed audio playback on iOS Safari 17.0+
  - Implemented correct iOS audio unlock pattern (silent sound before AudioContext resume)
  - Added iOS app lifecycle management for background/foreground transitions
  - Exposed AudioContext to window for debugging
  - Added comprehensive logging for audio state diagnostics
- **Testing Infrastructure**: Created TestSprite-based iOS audio diagnostic test suite
  - 6 specialized tests for iOS audio verification
  - iPhone 15 Pro Max WebKit simulation in Playwright
  - Automated AudioContext state monitoring
  - Soundfont loading verification
- **Search Counter Alignment**: Fixed visual alignment of search result counter with folder counters

### v0.9.4 (2025-11-09)
- **Smart File Display**: Left truncation for files in folders to show instrument names
- **File Counter Badges**: Folders show total number of music files (including subfolders)
- **Material Design Icons**: Folder icons with proper spacing
- **Welcome Screen**: Quick Tips for keyboard shortcuts
- **CSS Improvements**: Fixed folder expansion and counter positioning

### v0.9.3 (2025-11-09)
- **Internationalization**: Full i18n support for Score Folders settings
- **Folder Browser**: Navigate and select folders interactively
- **Security**: Path traversal prevention in folder validation

### v0.9.2 (2025-11-09)
- Added support for Nextcloud 32.0.1
- Updated PHP minimum requirement to 8.1
- Extended compatibility to Nextcloud 33.x
- Database schema updates

### v0.9.1 (2025-11-09)
- Added support for Nextcloud 31.0.10
- Extended compatibility to Nextcloud 32.x
- Updated PHP support to 8.4

### v0.9.0 (2025-11-08)
- Initial public release
- Full MusicXML playback support
- Admin settings panel
- Multi-folder support
- Smart search and navigation

## License

AGPL-3.0-or-later

## Credits

- Built with [OpenSheetMusicDisplay](https://opensheetmusicdisplay.org/)

## Support

For issues and feature requests, please use the issue tracker on the repository.
