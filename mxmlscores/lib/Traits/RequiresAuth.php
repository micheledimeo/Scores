<?php
/**
 * SPDX-FileCopyrightText: 2025 Michele <michele@ottoniascoppio.org>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Scores\Traits;

use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http;

/**
 * Trait for controllers requiring user authentication
 *
 * Provides a reusable method to check if a user is logged in.
 * Use this trait in controllers that require authenticated access.
 */
trait RequiresAuth {

	/**
	 * Check if user is authenticated
	 *
	 * @return DataResponse|null Returns error response if not authenticated, null if OK
	 */
	protected function checkAuth(): ?DataResponse {
		if ($this->userId === null) {
			return new DataResponse(
				['error' => 'User not logged in'],
				Http::STATUS_UNAUTHORIZED
			);
		}
		return null;
	}
}
