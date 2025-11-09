<?php
/**
 * SPDX-FileCopyrightText: 2025 Michele <michele@ottoniascoppio.org>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Scores\Service;

use OCP\AppFramework\Http\ContentSecurityPolicy;

/**
 * Content Security Policy configuration service
 *
 * Centralizes CSP configuration for the Scores app to ensure
 * consistent security policy across all endpoints.
 */
class CspService {

	/**
	 * Get the Content Security Policy for Scores app
	 *
	 * Configured to allow:
	 * - Soundfont loading from gleitz.github.io (OpenSheetMusicDisplay requirement)
	 * - Blob URLs for audio playback
	 * - unsafe-eval for OpenSheetMusicDisplay dynamic code generation
	 *
	 * @return ContentSecurityPolicy
	 */
	public function getScoresPolicy(): ContentSecurityPolicy {
		$csp = new ContentSecurityPolicy();

		// Soundfont loading (required by OpenSheetMusicDisplay playback)
		$csp->addAllowedConnectDomain('https://gleitz.github.io');
		$csp->addAllowedMediaDomain('https://gleitz.github.io');

		// Blob URLs for audio playback (Web Audio API)
		$csp->addAllowedMediaDomain('blob:');

		// WARNING: unsafe-eval is a security risk
		// Required by OpenSheetMusicDisplay for dynamic code generation
		// TODO: Investigate if this can be removed in future OSMD versions
		// See: https://github.com/opensheetmusicdisplay/opensheetmusicdisplay/issues/XXX
		$csp->addAllowedScriptDomain("'unsafe-eval'");

		return $csp;
	}
}
