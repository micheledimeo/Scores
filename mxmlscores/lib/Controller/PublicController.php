<?php
declare(strict_types=1);

namespace OCA\Scores\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\ContentSecurityPolicy;
use OCP\IRequest;
use OCP\Share\IManager as ShareManager;
use OCP\Share\Exceptions\ShareNotFound;
use OCP\Util;
use OCP\IInitialState;

class PublicController extends Controller {
    private ShareManager $shareManager;
    private IInitialState $initialState;

    public function __construct(
        string $appName,
        IRequest $request,
        ShareManager $shareManager,
        IInitialState $initialState
    ) {
        parent::__construct($appName, $request);
        $this->shareManager = $shareManager;
        $this->initialState = $initialState;
    }

    /**
     * @PublicPage
     * @NoCSRFRequired
     */
    public function showShare(string $token): TemplateResponse {
        try {
            // Validate share token
            $share = $this->shareManager->getShareByToken($token);
            
            // Check if share is valid
            if ($share->getPassword() !== null) {
                // TODO: Add password protection support
                return new TemplateResponse('core', '403', [], 'guest');
            }

            $node = $share->getNode();
            
            if (!($node instanceof \OCP\Files\File)) {
                return new TemplateResponse('core', '404', [], 'guest');
            }

            // Check if it's a MusicXML file
            // IMPORTANTE: mxml è l'estensione principale per MusicXML non compresso
            $extension = strtolower(pathinfo($node->getName(), PATHINFO_EXTENSION));
            $supportedExtensions = ['mxml', 'xml', 'musicxml', 'mxl', 'mei', 'gp', 'gpx', 'gp3', 'gp4', 'gp5'];

            if (!in_array($extension, $supportedExtensions)) {
                return new TemplateResponse('core', '404', [], 'guest');
            }

            // Security: Prevent memory exhaustion from large files
            $maxFileSize = 50 * 1024 * 1024; // 50 MB limit
            if ($node->getSize() > $maxFileSize) {
                return new TemplateResponse('core', '413', ['message' => 'File too large'], 'guest');
            }

            // Load scripts and styles
            // CRITICAL: Load init-app.js FIRST to set appName before @nextcloud/vue loads
            Util::addScript($this->appName, 'init-app');
            Util::addScript($this->appName, 'mxml-scores-main');
            Util::addStyle($this->appName, 'main');

            // Get file content
            $content = $node->getContent();
            $base64Content = base64_encode($content);

            // Use InitialState to provide data to frontend (Nextcloud best practice)
            $this->initialState->provideInitialState('publicShare', [
                'fileName' => $node->getName(),
                'fileContent' => $base64Content,
                'isPublicShare' => true,
                'token' => $token
            ]);

            $response = new TemplateResponse($this->appName, 'public', [], 'guest');

            // Set custom Content Security Policy for audio playback
            $csp = new ContentSecurityPolicy();
            $csp->addAllowedConnectDomain('https://gleitz.github.io');
            $csp->addAllowedMediaDomain('https://gleitz.github.io');
            $csp->addAllowedMediaDomain('blob:');
            $csp->addAllowedScriptDomain("'unsafe-eval'");  // Required for OSMD

            $response->setContentSecurityPolicy($csp);
            
            return $response;
            
        } catch (ShareNotFound $e) {
            return new TemplateResponse('core', '404', [], 'guest');
        } catch (\Exception $e) {
            \OC::$server->getLogger()->error('Error in showShare: ' . $e->getMessage(), ['app' => 'mxml-scores']);
            return new TemplateResponse('core', '500', [], 'guest');
        }
    }
}
