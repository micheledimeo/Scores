/**
 * MuseScore to MusicXML converter using webmscore (WebAssembly)
 * Converts .mscz and .mscx files to MusicXML for OSMD playback
 *
 * License: GPL (webmscore) - Compatible with AGPL-3.0
 */

let WebMscore = null
let isLoading = false
let loadPromise = null

/**
 * Lazy-load webmscore module (only when needed)
 * The module is ~8-10 MB, so we defer loading until a MuseScore file is encountered
 *
 * @returns {Promise<Object>} The loaded webmscore module
 */
async function loadWebMscore() {
	if (WebMscore) {
		return WebMscore
	}

	if (isLoading) {
		return loadPromise
	}

	isLoading = true
	console.log('[MuseScoreConverter] Loading webmscore module (this may take a few seconds)...')

	loadPromise = (async () => {
		try {
			const module = await import('webmscore')
			WebMscore = module.default
			await WebMscore.ready
			console.log('[MuseScoreConverter] webmscore loaded successfully')
			return WebMscore
		} catch (error) {
			console.error('[MuseScoreConverter] Failed to load webmscore:', error)
			isLoading = false
			loadPromise = null
			throw error
		}
	})()

	return loadPromise
}

/**
 * Check if filename is a MuseScore file
 *
 * @param {string} filename - The filename to check
 * @returns {boolean} True if the file is a MuseScore file (.mscz or .mscx)
 */
export function isMuseScoreFile(filename) {
	if (!filename) return false
	return /\.(mscz|mscx)$/i.test(filename)
}

/**
 * Convert MuseScore file to MusicXML string
 *
 * @param {ArrayBuffer|Uint8Array} fileData - Raw file bytes
 * @param {string} filename - Original filename (to detect format)
 * @returns {Promise<string>} MusicXML content as string
 * @throws {Error} If conversion fails
 */
export async function convertToMusicXML(fileData, filename) {
	console.log(`[MuseScoreConverter] Starting conversion of ${filename}`)

	// Load webmscore module (lazy loading)
	const mscore = await loadWebMscore()

	// Determine format from extension
	const format = filename.toLowerCase().endsWith('.mscz') ? 'mscz' : 'mscx'
	console.log(`[MuseScoreConverter] Detected format: ${format}`)

	// Ensure we have Uint8Array
	const data = fileData instanceof Uint8Array
		? fileData
		: new Uint8Array(fileData)

	console.log(`[MuseScoreConverter] File size: ${data.length} bytes`)

	try {
		// Load score
		console.log('[MuseScoreConverter] Loading score into webmscore...')
		const score = await mscore.load(format, data)

		// Get metadata for logging
		const metadata = await score.metadata()
		console.log('[MuseScoreConverter] Score metadata:', metadata)

		// Export to uncompressed MusicXML
		console.log('[MuseScoreConverter] Exporting to MusicXML...')
		const musicxml = await score.saveXml()

		// Clean up WASM memory
		score.destroy()

		console.log(`[MuseScoreConverter] Conversion complete: ${musicxml.length} bytes of MusicXML`)

		return musicxml

	} catch (error) {
		console.error('[MuseScoreConverter] Conversion failed:', error)
		throw new Error(`Failed to convert MuseScore file: ${error.message}`)
	}
}

/**
 * Get MuseScore file information without full conversion
 * Useful for displaying file metadata before playback
 *
 * @param {ArrayBuffer|Uint8Array} fileData - Raw file bytes
 * @param {string} filename - Original filename
 * @returns {Promise<Object>} Metadata object
 */
export async function getMuseScoreMetadata(fileData, filename) {
	console.log(`[MuseScoreConverter] Getting metadata for ${filename}`)

	const mscore = await loadWebMscore()
	const format = filename.toLowerCase().endsWith('.mscz') ? 'mscz' : 'mscx'
	const data = fileData instanceof Uint8Array ? fileData : new Uint8Array(fileData)

	try {
		const score = await mscore.load(format, data)
		const metadata = await score.metadata()
		score.destroy()

		return metadata
	} catch (error) {
		console.error('[MuseScoreConverter] Failed to get metadata:', error)
		throw new Error(`Failed to read MuseScore metadata: ${error.message}`)
	}
}
