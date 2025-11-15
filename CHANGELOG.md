# Changelog

All notable changes to the Scores app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.8] - 2025-11-15

### Added
- Mobile-optimized playback controls layout with touch-friendly buttons
- Reversed mixer channel button order for better visual organization
- Flexbox-based vertical alignment for Welcome screen on mobile

### Changed
- **Mobile UX**: Welcome screen now aligns to top on mobile devices instead of center
- **Mobile UI**: Removed folder score counters from navigation sidebar
- **Mobile Layout**: Playback bar reorganized - controls and progress on first row, tempo/volume/zoom on second row
- **Quick Tips**: Moved "Use Files app" message into Quick Tips section
- **Quick Tips**: Added keyboard shortcuts documentation (F key for return to start, arrow keys for zoom)
- **Quick Tips**: Removed redundant + - keys from zoom instructions (only arrow keys now)
- Simplified Welcome screen by removing "Upload & Share" section
- Reduced top spacing on mobile Welcome screen for better space utilization

### Fixed
- Mobile playback bar no longer shows tempo/volume sliders (compact number inputs only)
- Progress bar stays on first row on mobile with proper flex layout
- Touch targets for all playback buttons meet minimum 44x44px accessibility guidelines
- AudioContext cleanup improved to reduce console warnings during score switching
- Mobile Welcome screen spacing significantly reduced with proper flexbox alignment

### Technical Improvements
- CSS transform removed in favor of proper flexbox alignment (align-items: flex-start)
- Playback controls use flex-shrink for responsive layout on mobile
- Input fields width reduced to 60px on mobile for better space efficiency
- Removed CSS for unused "Upload & Share" section
- Enhanced mobile media queries for better responsive behavior

## [0.9.7] - 2025-11-12

### Added
- Nextcloud App Store submission preparation
- Code signing certificate infrastructure
- Comprehensive test suite with Playwright
- GitHub Actions workflows for CI/CD and releases
- Production deployment automation scripts

### Changed
- App renamed from "mxmlscores" to "scores" for better branding
- Repository structure reorganized with project-files directory
- Improved documentation for deployment and App Store submission

### Fixed
- Dependabot automated updates disabled to reduce repository clutter
- Line ending consistency in backup files (CRLF to LF)
- GitHub repository configuration and remote URLs

### Technical Improvements
- Certificate Signing Request (CSR) generated for App Store
- Pull Request submitted to nextcloud/app-certificate-requests (#856)
- Package signing script with OpenSSL integration
- Enhanced build and deployment pipeline

## [0.9.6] - 2025-11-11

### Added
- Multiple Score Folders configuration support with JSON storage format
- Interactive folder browser in Score Folders settings
- Change detection for Score Folders settings (Save button disabled when no changes)
- Backward compatibility for old CSV-based folder configuration format
- Direct folder addition from Browse dialog (removed redundant Add button)
- Comprehensive backup and packaging scripts in project-files/scripts/

### Fixed
- **Critical**: Score Folders configuration key mismatch - ApiController now correctly reads from 'scores_folders' (JSON) instead of 'scores_folder' (CSV)
- **Critical**: Files in newly added Score Folders (e.g., MieScores) now appear correctly in the scores list
- Score Folders settings now properly trigger recursive folder scan and file list refresh after Save
- Improved state management for Score Folders with original state tracking

### Changed
- Score Folders UI streamlined: Browse → Confirm now directly adds folders to list
- Save button in Score Folders settings only enabled when changes are detected
- Enhanced ApiController.php to support both JSON array and CSV fallback for folder paths
- Updated package-app.sh to include LICENSE and CHANGELOG.md in distribution
- Version bump from 0.9.5 to 0.9.6 in info.xml and package.json

### Technical Improvements
- Added `originalScoresFolderPaths` ref for change tracking in App.vue
- Added `hasPathsChanged` computed property for intelligent Save button state
- Improved `confirmFolderSelection()` to add folders directly to list
- Enhanced `saveScoresFolder()` to update original state after successful save
- Added proper JSON decoding with fallback to CSV in ApiController.php listFiles()

## [0.9.5] - 2025-11-10

### Added
- **iOS/iPadOS Audio Support**: Comprehensive audio playback support for iOS Safari 17.0+
  - Correct iOS audio unlock pattern (silent sound before AudioContext resume)
  - iOS app lifecycle management for background/foreground transitions
  - Exposed AudioContext to window for debugging capabilities
  - Comprehensive logging for audio state diagnostics
- **Testing Infrastructure**: TestSprite-based iOS audio diagnostic test suite
  - 6 specialized tests for iOS audio verification
  - iPhone 15 Pro Max WebKit simulation in Playwright
  - Automated AudioContext state monitoring
  - Soundfont loading verification with network request tracking

### Fixed
- Search counter alignment now matches folder counter position
- iOS Safari audio context state management
- Background/foreground audio state transitions on iOS

### Changed
- Improved Quick Tips display with clear keyboard shortcut formatting
- Updated keyboard shortcuts documentation (↑ ↓ for zoom, F for fullscreen)

## [0.9.4] - 2025-11-09

### Added
- Smart file name truncation from left for files in folders (max 30 chars + "...")
- File counter badges on folders showing total number of music files (including subfolders)
- Material Design folder icons with proper spacing
- Search result counter overlay aligned with folder counters
- Welcome screen with Quick Tips for keyboard shortcuts

### Fixed
- Folder expansion state management with proper Vue 3 Set reactivity
- CSS specificity issues for file name display in folders
- Counter bubble positioning alignment between search and folders
- Icon display and spacing in folder navigation

### Changed
- Optimized file display: files in folders truncate from left to show instrument names
- Root-level files have minimal left padding (5px) for better alignment
- Files in folders align with folder names (36px padding after folder icon)
- Improved CSS with text-overflow: clip for better rendering performance
- Enhanced event handling with @update:open for NcAppNavigationItem components

### Technical Improvements
- Added `formatFileNameForDisplay()` function for intelligent truncation
- Enhanced CSS specificity for Nextcloud component override
- Proper Vue 3 reactivity with expandedFolders Set
- Counter positioning with absolute positioning and transform

## [0.9.3] - 2025-11-09

### Added
- Full internationalization (i18n) support for Score Folders settings
- Translatable strings for all settings UI elements
- Folder browser with navigation and selection capabilities
- Multiple folder paths configuration UI

### Fixed
- Translation keys for Score Folders settings modal
- Folder path validation and security (path traversal prevention)

### Changed
- Score Folders settings now support multiple paths as JSON array
- Improved settings modal layout and user experience
- Enhanced folder browsing with parent navigation

## [0.9.2] - 2025-11-09

### Added
- Support for Nextcloud 32.0.1
- Extended compatibility to Nextcloud 33.x
- Database schema updates for newer Nextcloud versions

### Changed
- Updated PHP minimum requirement to 8.1
- Extended max Nextcloud version to 33

## [0.9.1] - 2025-11-09

### Added
- Support for Nextcloud 31.0.10
- Extended compatibility to Nextcloud 32.x
- PHP 8.4 support

### Changed
- Updated PHP max version to 8.4
- Extended Nextcloud compatibility range

## [0.9.0] - 2025-11-08

### Added
- Initial public release
- Full MusicXML rendering with OpenSheetMusicDisplay
- Advanced playback controls with play, pause, stop, loop
- Instrument mixer with per-channel volume control and solo/mute
- Tempo control (40-240 BPM) with numeric input
- Master volume control (0-100) with numeric input
- Visual progress bar with time and measure indicators
- Real-time cursor tracking during playback
- Keyboard shortcuts: Space (play/pause), arrows (navigate), +/- (zoom)
- Smart search with real-time filtering across folders and files
- Folder navigation with expandable/collapsible folders
- Admin settings panel for configuring scores folder paths
- Multi-folder support for organizing music library
- Support for MusicXML (.xml, .mxml, .musicxml), compressed MusicXML (.mxl)
- Support for MEI and Guitar Pro formats (.gp, .gp3, .gp4, .gp5, .gpx)
- Responsive design with collapsible sidebar
- Material Design icons integration (library_music app icon)
- Files app integration for upload and sharing

### Technical Details
- Vue 3 Composition API frontend
- Vite build system with optimized bundling
- PHP 8.1+ backend with Nextcloud APIs
- OpenSheetMusicDisplay for music rendering
- Nextcloud Vue components for consistent UI
- Custom MixerInstrumentPlayer for advanced audio control

## [Unreleased]

### Planned Features
- Public share functionality for scores
- Playlist creation and management
- Score annotations and bookmarks
- Print-friendly score rendering
- MIDI export capabilities
- Transposition controls
- Metronome integration

---

[0.9.8]: https://github.com/micheledimeo/scores/releases/tag/v0.9.8
[0.9.7]: https://github.com/micheledimeo/scores/releases/tag/v0.9.7
[0.9.6]: https://github.com/micheledimeo/scores/releases/tag/v0.9.6
[0.9.5]: https://github.com/micheledimeo/scores/releases/tag/v0.9.5
[0.9.4]: https://github.com/micheledimeo/scores/releases/tag/v0.9.4
[0.9.3]: https://github.com/micheledimeo/scores/releases/tag/v0.9.3
[0.9.2]: https://github.com/micheledimeo/scores/releases/tag/v0.9.2
[0.9.1]: https://github.com/micheledimeo/scores/releases/tag/v0.9.1
[0.9.0]: https://github.com/micheledimeo/scores/releases/tag/v0.9.0
