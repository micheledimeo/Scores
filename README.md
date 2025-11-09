# Scores for Nextcloud

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

## Recent Improvements (Pre-TestSprite Version)

### UI/UX Enhancements
- **Smart File Truncation**: Files in folders automatically truncate from the left (max 36 chars + "...") to ensure instrument names are always visible on the right
- **Folder Icons**: Material Design folder icons with proper spacing
- **File Count Badges**: Each folder shows the number of files it contains
- **Optimized Spacing**: Root files have 5px left padding for better alignment
- **Icon Management**: File icons hidden in folder view to maximize space for file names

### Search & Navigation
- **Match Counter**: Search box displays total number of matching files
- **Expandable Folders**: Click folders to expand/collapse and view contained files
- **Real-time Filtering**: Search applies to both folder names and file names

### Settings & Configuration
- **Translation System**: Full i18n support with translatable strings for "Scores Folders" settings
- **Multiple Folder Paths**: Administrators can configure multiple scores folder locations
- **Folder Browser**: Interactive folder navigation for selecting scores directories
- **App Icon**: Custom library_music Material Design icon

### Technical Improvements
- **CSS Specificity Optimization**: Proper CSS rules to override Nextcloud defaults
- **Vue 3 Reactivity**: Fixed folder expansion state management with proper Set reactivity
- **Event Handling**: Proper @update:open event handling for NcAppNavigationItem components
- **Performance**: Optimized CSS with text-overflow: clip for better rendering

## Installation

### Prerequisites

- Nextcloud 28.x - 33.x
- PHP 8.1 or later (8.2+ recommended)
- Node.js 20 or later
- npm 10 or later

### Development Setup

1. Clone or copy this directory to your Nextcloud `apps/` folder
2. Install dependencies:
   ```bash
   npm install
   ```
3. Build the app:
   ```bash
   npm run build
   ```
4. Enable the app in Nextcloud:
   ```bash
   php occ app:enable mxmlscores
   ```

### Production Build

For production, run:
```bash
npm run build
```

This will create optimized files in the `js/` directory.

### Development Mode

For development with hot reload:
```bash
npm run watch
```

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
mxmlscores/
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
└── README.md             # This file
```

## Technologies Used

- **OpenSheetMusicDisplay**: Music notation rendering
- **Vue 3**: Frontend framework
- **Vite**: Build tool
- **Nextcloud Vue Components**: UI components
- **PHP 8.1+**: Backend API

## Version History

### v0.9.2 (2025-11-09)
- Added support for Nextcloud 32.0.1
- Updated PHP minimum requirement to 8.1
- Extended compatibility to Nextcloud 33.x
- Database schema updates

### v0.9.1 (2025-11-09)
- Added support for Nextcloud 31.0.10
- Extended compatibility to Nextcloud 32.x
- Updated PHP support to 8.4

### v0.9.0
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
