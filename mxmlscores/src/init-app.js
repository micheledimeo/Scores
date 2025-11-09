/**
 * Scores - Initialization Script
 *
 * CRITICAL: This file must be loaded BEFORE the main bundle to prevent
 * "@nextcloud/vue: The library was used without setting appName" error
 *
 * This sets up the appName in the global scope before any Vue components
 * are imported and initialized.
 */

// Initialize OCA namespace structure
window.OCA = window.OCA || {}
window.OCA.Scores = window.OCA.Scores || {}

// Set appName for @nextcloud/vue
window.OCA.Scores.appName = 'mxmlscores'

// Also set on window for compatibility
window.appName = 'mxmlscores'

// Log successful initialization (useful for debugging)
console.log('[Scores] App name initialized:', window.appName)
