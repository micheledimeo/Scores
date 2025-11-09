<?php
/**
 * SPDX-FileCopyrightText: 2025 Michele <michele@ottoniascoppio.org>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Scores\Traits;

use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http;

/**
 * Trait for controllers requiring admin privileges
 *
 * Provides a reusable method to check if the current user has admin privileges.
 * Use this trait in controllers that require admin access.
 *
 * Note: This trait requires RequiresAuth trait and $groupManager to be available
 */
trait RequiresAdmin {
	use RequiresAuth;

	/**
	 * Check if user is authenticated and has admin privileges
	 *
	 * @return DataResponse|null Returns error response if not authorized, null if OK
	 */
	protected function checkAdminAccess(): ?DataResponse {
		// First check authentication
		if ($authError = $this->checkAuth()) {
			return $authError;
		}

		// Then check admin privileges
		if (!$this->groupManager->isAdmin($this->userId)) {
			return new DataResponse(
				['error' => 'Admin access required'],
				Http::STATUS_FORBIDDEN
			);
		}

		return null;
	}
}
