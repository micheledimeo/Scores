<?php
/**
 * SPDX-FileCopyrightText: 2025 Michele <michele@ottoniascoppio.org>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Scores\AppInfo;

use OCA\Scores\Service\CspService;
use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;
use OCP\AppFramework\Bootstrap\IRegistrationContext;

class Application extends App implements IBootstrap {
	public const APP_ID = 'mxmlscores';

	public function __construct(array $urlParams = []) {
		parent::__construct(self::APP_ID, $urlParams);
	}

	public function register(IRegistrationContext $context): void {
		// Register services for dependency injection
		$context->registerService(CspService::class, function () {
			return new CspService();
		});
	}

	public function boot(IBootContext $context): void {
		// Boot logic if needed
	}
}
