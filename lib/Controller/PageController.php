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

        // Set custom Content Security Policy for audio playback and MuseScore conversion
        $csp = new ContentSecurityPolicy();

        // Audio playback (soundfonts from gleitz.github.io)
        $csp->addAllowedConnectDomain('https://gleitz.github.io');
        $csp->addAllowedMediaDomain('https://gleitz.github.io');
        $csp->addAllowedMediaDomain('blob:');

        // MuseScore conversion (webmscore WASM files from jsdelivr CDN)
        $csp->addAllowedConnectDomain('https://cdn.jsdelivr.net');

        // Required for OSMD and webmscore
        $csp->addAllowedScriptDomain("'unsafe-eval'");

        // Allow Web Workers for webmscore (MuseScore file conversion)
        // webmscore uses blob: URLs to create workers for WASM execution
        $csp->addAllowedWorkerSrcDomain("'self'");
        $csp->addAllowedWorkerSrcDomain('blob:');

        $response->setContentSecurityPolicy($csp);
        
        return $response;
    }
}
