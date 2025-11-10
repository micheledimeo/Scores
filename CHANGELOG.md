# Changelog

All notable changes to the MusicXML Scores for Nextcloud app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.5] - 2025-11-10

### Added
- iOS/iPadOS audio playback support for Safari 17.0+
- Comprehensive iOS audio diagnostic test suite using TestSprite
- AudioContext window exposure for debugging
- Detailed audio state logging for diagnostics
- iOS app lifecycle management (visibilitychange events)
- iPhone 15 Pro Max simulation in Playwright test configuration

### Fixed
- **Critical**: iOS audio unlock pattern - silent sound now plays BEFORE AudioContext.resume()
- AudioContext suspension when iOS app goes to background
- Search counter alignment with folder counters in sidebar

### Technical
- Added 6 specialized iOS audio diagnostic tests
- Implemented WebKit browser support in Playwright
- Enhanced logging for AudioContext state transitions
- Proper iOS audio unlock sequence (3-step pattern)

## [0.9.2] - 2025-11-09

### Added
- Support for Nextcloud 32.0.1
- Extended compatibility to Nextcloud 33.x
- Database schema updates

### Changed
- Updated PHP minimum requirement to 8.1
- Updated dependencies for Nextcloud 32+ compatibility

## [0.9.1] - 2025-11-09

### Added
- Support for Nextcloud 31.0.10
- Extended compatibility to Nextcloud 32.x
- PHP 8.4 support

### Changed
- Updated PHP version range to 8.1-8.4

## [0.9.0] - 2025-11-08

### Added
- Initial public release
- MusicXML file rendering using OpenSheetMusicDisplay
- Advanced playback controls (play, pause, stop, loop)
- Instrument mixer with individual channel control
- Tempo and volume adjustment with numeric inputs
- Progress tracking with time and measure indicators
- Keyboard shortcuts for playback and navigation
- Smart search with real-time filtering and match counter
- Folder organization with expandable/collapsible folders
- Smart file display with left truncation in folders
- Admin settings panel with folder path configuration
- Multiple scores folder support
- Internationalization (i18n) support
- Custom Material Design icons
- Responsive layout with collapsible sidebar
- Public share support for scores

### Supported Formats
- MusicXML (.xml, .musicxml, .mxml)
- MusicXML Compressed (.mxl)
- MEI (Music Encoding Initiative)
- Guitar Pro files (.gp, .gp3, .gp4, .gp5, .gpx)

### Compatibility
- Nextcloud 28.x - 33.x
- PHP 8.1 - 8.4
- Node.js 20.x+
- npm 10.x+
- Modern browsers (Chrome, Firefox, Safari including iOS/iPadOS)

[0.9.5]: https://github.com/micheledimeo/mxmlscores/compare/v0.9.2...v0.9.5
[0.9.2]: https://github.com/micheledimeo/mxmlscores/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/micheledimeo/mxmlscores/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/micheledimeo/mxmlscores/releases/tag/v0.9.0
