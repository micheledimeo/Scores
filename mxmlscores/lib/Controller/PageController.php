<?php
declare(strict_types=1);

namespace OCA\Scores\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\ContentSecurityPolicy;
use OCP\IRequest;
use OCP\Util;

class PageController extends Controller {
    public function __construct(
        string $appName,
        IRequest $request
    ) {
        parent::__construct($appName, $request);
    }

    /**
     * @NoAdminRequired
     * @NoCSRFRequired
     */
    public function index(): TemplateResponse {
        // CRITICAL: Load init-app.js FIRST to set appName before @nextcloud/vue components load
        Util::addScript($this->appName, 'init-app');
        Util::addScript($this->appName, 'mxml-scores-main');
        Util::addStyle($this->appName, 'main');
        
        $response = new TemplateResponse($this->appName, 'main');

        // Set custom Content Security Policy for audio playback
        $csp = new ContentSecurityPolicy();
        $csp->addAllowedConnectDomain('https://gleitz.github.io');
        $csp->addAllowedMediaDomain('https://gleitz.github.io');
        $csp->addAllowedMediaDomain('blob:');
        $csp->addAllowedScriptDomain("'unsafe-eval'");  // Required for OSMD

        $response->setContentSecurityPolicy($csp);
        
        return $response;
    }
}
