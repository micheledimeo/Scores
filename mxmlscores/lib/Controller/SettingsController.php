<?php
declare(strict_types=1);

namespace OCA\Scores\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;
use OCP\IConfig;
use OCP\IRequest;
use OCP\IGroupManager;
use OCP\Files\IRootFolder;
use OCP\Files\NotFoundException;

class SettingsController extends Controller {
    private IConfig $config;
    private IGroupManager $groupManager;
    private IRootFolder $rootFolder;
    private ?string $userId;

    public function __construct(
        string $appName,
        IRequest $request,
        IConfig $config,
        IGroupManager $groupManager,
        IRootFolder $rootFolder,
        ?string $userId
    ) {
        parent::__construct($appName, $request);
        $this->config = $config;
        $this->groupManager = $groupManager;
        $this->rootFolder = $rootFolder;
        $this->userId = $userId;
    }

    /**
     * @NoAdminRequired
     */
    public function isAdmin(): DataResponse {
        if ($this->userId === null) {
            return new DataResponse(['isAdmin' => false], Http::STATUS_UNAUTHORIZED);
        }

        $isAdmin = $this->groupManager->isAdmin($this->userId);
        return new DataResponse(['isAdmin' => $isAdmin]);
    }

    /**
     * @NoAdminRequired
     */
    public function getScoresFolder(): DataResponse {
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        // Check if user is admin
        if (!$this->groupManager->isAdmin($this->userId)) {
            return new DataResponse(['error' => 'Admin access required'], Http::STATUS_FORBIDDEN);
        }

        // Try to get array of folder paths (new format)
        $folderPathsJson = $this->config->getAppValue($this->appName, 'scores_folders', '');
        if (!empty($folderPathsJson)) {
            $folderPaths = json_decode($folderPathsJson, true);
            if (is_array($folderPaths)) {
                return new DataResponse(['folderPaths' => $folderPaths]);
            }
        }

        // Fallback: try old single path format for backward compatibility
        $folderPath = $this->config->getAppValue($this->appName, 'scores_folder', '');
        if (!empty($folderPath)) {
            return new DataResponse(['folderPath' => $folderPath]);
        }

        return new DataResponse(['folderPaths' => []]);
    }

    /**
     * @NoAdminRequired
     */
    public function setScoresFolder(array $folderPaths = null): DataResponse {
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        // Check if user is admin
        if (!$this->groupManager->isAdmin($this->userId)) {
            return new DataResponse(['error' => 'Admin access required'], HTTP::STATUS_FORBIDDEN);
        }

        // Handle null or empty array
        if ($folderPaths === null) {
            $folderPaths = [];
        }

        // Validate and sanitize each folder path
        $validatedPaths = [];
        $userFolder = null;

        try {
            $userFolder = $this->rootFolder->getUserFolder($this->userId);
        } catch (\Exception $e) {
            return new DataResponse(['error' => 'Cannot access user folder'], Http::STATUS_INTERNAL_SERVER_ERROR);
        }

        foreach ($folderPaths as $path) {
            // Remove leading/trailing slashes
            $path = trim($path, '/');

            // Security: Prevent path traversal attacks
            if (str_contains($path, '..') || str_contains($path, '\\')) {
                return new DataResponse(['error' => 'Invalid path: path traversal not allowed in: ' . $path], Http::STATUS_BAD_REQUEST);
            }

            // Verify folder exists (empty path means root, which is valid)
            if (!empty($path)) {
                try {
                    $targetFolder = $userFolder->get($path);
                    if (!($targetFolder instanceof \OCP\Files\Folder)) {
                        return new DataResponse(['error' => 'Path is not a folder: ' . $path], Http::STATUS_BAD_REQUEST);
                    }
                } catch (NotFoundException $e) {
                    return new DataResponse(['error' => 'Folder not found: ' . $path], Http::STATUS_NOT_FOUND);
                }
            }

            $validatedPaths[] = $path;
        }

        // Save to app config as JSON
        $this->config->setAppValue($this->appName, 'scores_folders', json_encode($validatedPaths));

        return new DataResponse(['success' => true, 'folderPaths' => $validatedPaths]);
    }

    /**
     * @NoAdminRequired
     */
    public function browseFolders(string $path = ''): DataResponse {
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        // Check if user is admin
        if (!$this->groupManager->isAdmin($this->userId)) {
            return new DataResponse(['error' => 'Admin access required'], Http::STATUS_FORBIDDEN);
        }

        try {
            $userFolder = $this->rootFolder->getUserFolder($this->userId);

            // Security: Prevent path traversal attacks
            if (str_contains($path, '..') || str_contains($path, '\\')) {
                return new DataResponse(['error' => 'Invalid path: path traversal not allowed'], Http::STATUS_BAD_REQUEST);
            }

            // Get target folder
            $targetFolder = $userFolder;
            if (!empty($path)) {
                $targetFolder = $userFolder->get($path);
                if (!($targetFolder instanceof \OCP\Files\Folder)) {
                    return new DataResponse(['error' => 'Not a folder'], Http::STATUS_BAD_REQUEST);
                }
            }

            // Get only folders (not files)
            $folders = [];
            foreach ($targetFolder->getDirectoryListing() as $node) {
                if ($node instanceof \OCP\Files\Folder) {
                    $relativePath = empty($path) ? $node->getName() : $path . '/' . $node->getName();
                    $folders[] = [
                        'id' => $node->getId(),
                        'name' => $node->getName(),
                        'path' => $relativePath
                    ];
                }
            }

            // Sort folders alphabetically
            usort($folders, function($a, $b) {
                return strcasecmp($a['name'], $b['name']);
            });

            return new DataResponse([
                'folders' => $folders,
                'currentPath' => $path
            ]);

        } catch (NotFoundException $e) {
            return new DataResponse(['error' => 'Folder not found'], Http::STATUS_NOT_FOUND);
        } catch (\Exception $e) {
            \OC::$server->getLogger()->error('Error in browseFolders: ' . $e->getMessage(), ['app' => 'mxml-scores']);
            return new DataResponse(['error' => 'Failed to browse folders'], Http::STATUS_INTERNAL_SERVER_ERROR);
        }
    }
}
