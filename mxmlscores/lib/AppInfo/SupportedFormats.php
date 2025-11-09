<?php
/**
 * SPDX-FileCopyrightText: 2025 Michele <michele@ottoniascoppio.org>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Scores\AppInfo;

/**
 * Supported music file formats
 *
 * Centralizes the list of supported file extensions for music scores.
 * Single source of truth for file type validation across the application.
 */
class SupportedFormats {

	/**
	 * List of supported file extensions
	 *
	 * - mxml: MusicXML uncompressed (primary format)
	 * - xml: Generic XML (MusicXML compatible)
	 * - musicxml: MusicXML explicit extension
	 * - mxl: MusicXML compressed
	 * - mei: Music Encoding Initiative format
	 * - gp, gpx, gp3-gp5: Guitar Pro formats
	 */
	public const EXTENSIONS = [
		'mxml',     // MusicXML uncompressed (primary)
		'xml',      // Generic XML (MusicXML)
		'musicxml', // MusicXML explicit
		'mxl',      // MusicXML compressed
		'mei',      // Music Encoding Initiative
		'gp',       // Guitar Pro
		'gpx',      // Guitar Pro 6
		'gp3',      // Guitar Pro 3
		'gp4',      // Guitar Pro 4
		'gp5',      // Guitar Pro 5
	];

	/**
	 * Check if a file extension is supported
	 *
	 * @param string $extension File extension (case-insensitive)
	 * @return bool True if extension is supported
	 */
	public static function isSupported(string $extension): bool {
		return in_array(strtolower($extension), self::EXTENSIONS, true);
	}

	/**
	 * Get regex pattern for file matching
	 *
	 * @return string Regex pattern like "\.(mxml|xml|...)$"
	 */
	public static function getRegexPattern(): string {
		return '\.(' . implode('|', self::EXTENSIONS) . ')$';
	}
}
