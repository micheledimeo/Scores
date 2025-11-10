<?php
declare(strict_types=1);

namespace OCA\Scores\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http\DataDisplayResponse;
use OCP\Files\IRootFolder;
use OCP\Files\NotFoundException;
use OCP\IRequest;
use OCP\IConfig;
use OCP\Share\IManager as ShareManager;
use OCP\IURLGenerator;

class ApiController extends Controller {
    private IRootFolder $rootFolder;
    private ?string $userId;
    private IConfig $config;
    private ShareManager $shareManager;
    private IURLGenerator $urlGenerator;

    public function __construct(
        string $appName,
        IRequest $request,
        IRootFolder $rootFolder,
        IConfig $config,
        ShareManager $shareManager,
        IURLGenerator $urlGenerator,
        ?string $userId
    ) {
        parent::__construct($appName, $request);
        $this->rootFolder = $rootFolder;
        $this->config = $config;
        $this->shareManager = $shareManager;
        $this->urlGenerator = $urlGenerator;
        $this->userId = $userId;
    }

    /**
     * @NoAdminRequired
     */
    public function getFile(int $fileId): DataResponse {
        // Check authentication
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        // Validate fileId
        if ($fileId <= 0) {
            return new DataResponse(['error' => 'Invalid file ID'], Http::STATUS_BAD_REQUEST);
        }

        try {

            $userFolder = $this->rootFolder->getUserFolder($this->userId);
            $files = $userFolder->getById($fileId);
            
            if (count($files) === 0) {
                return new DataResponse(['error' => 'File not found'], Http::STATUS_NOT_FOUND);
            }
            
            $file = $files[0];
            
            if (!($file instanceof \OCP\Files\File)) {
                return new DataResponse(['error' => 'Not a file'], Http::STATUS_BAD_REQUEST);
            }

            $content = $file->getContent();
            $mimeType = $file->getMimeType();
            
            return new DataResponse([
                'content' => base64_encode($content),
                'mimeType' => $mimeType,
                'name' => $file->getName(),
                'size' => $file->getSize()
            ]);

        } catch (NotFoundException $e) {
            return new DataResponse(['error' => 'File not found'], Http::STATUS_NOT_FOUND);
        } catch (\Exception $e) {
            \OC::$server->getLogger()->error('Error in getFile: ' . $e->getMessage(), ['app' => 'mxml-scores']);
            return new DataResponse(['error' => 'Failed to retrieve file'], Http::STATUS_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * @NoAdminRequired
     */
    public function listFiles(): DataResponse {
        // Check authentication
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        try {

            $userFolder = $this->rootFolder->getUserFolder($this->userId);

            // Get configured scores folder paths (comma-separated)
            $scoresFolderConfig = $this->config->getAppValue($this->appName, 'scores_folder', '');

            // Estensioni supportate per file MusicXML e formati musicali
            // IMPORTANTE: .mxml è l'estensione principale per MusicXML non compresso
            $supportedExtensions = ['mxml', 'xml', 'musicxml', 'mxl', 'mei', 'gp', 'gpx', 'gp3', 'gp4', 'gp5'];

            $allFolders = [];
            $allFiles = [];

            // If specific folders are configured, scan each one recursively
            if (!empty($scoresFolderConfig)) {
                $configuredPaths = array_map('trim', explode(',', $scoresFolderConfig));

                foreach ($configuredPaths as $scoresFolder) {
                    if (empty($scoresFolder)) {
                        continue;
                    }

                    try {
                        $targetFolder = $userFolder->get($scoresFolder);
                        if (!($targetFolder instanceof \OCP\Files\Folder)) {
                            \OC::$server->getLogger()->warning('Configured path is not a folder: ' . $scoresFolder, ['app' => 'mxml-scores']);
                            continue;
                        }

                        // Build folder structure for this configured folder
                        $structure = $this->buildFolderStructure($targetFolder, $supportedExtensions);
                        $allFolders = array_merge($allFolders, $structure['folders']);
                        $allFiles = array_merge($allFiles, $structure['files']);

                    } catch (NotFoundException $e) {
                        \OC::$server->getLogger()->warning('Configured scores folder not found: ' . $scoresFolder, ['app' => 'mxml-scores']);
                        continue;
                    }
                }
            } else {
                // No specific folder configured, scan user's root folder
                $structure = $this->buildFolderStructure($userFolder, $supportedExtensions);
                $allFolders = $structure['folders'];
                $allFiles = $structure['files'];
            }

            return new DataResponse([
                'folders' => $allFolders,
                'files' => $allFiles
            ]);

        } catch (\Exception $e) {
            \OC::$server->getLogger()->error('Error in listFiles: ' . $e->getMessage(), ['app' => 'mxml-scores']);
            return new DataResponse(['error' => 'Failed to list files'], Http::STATUS_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Build folder structure for file listing
     *
     * @param \OCP\Files\Folder $folder The folder to scan
     * @param array $extensions Array of supported file extensions
     * @param string $path Current path (for recursion)
     * @return array Structure with 'folders' and 'files' arrays
     */
    private function buildFolderStructure(\OCP\Files\Folder $folder, array $extensions, string $path = ''): array {
        $folders = [];
        $files = [];

        // Solo primo livello di cartelle (visualizzazione flat)
        foreach ($folder->getDirectoryListing() as $node) {
            if ($node instanceof \OCP\Files\Folder) {
                // Raccoglie TUTTI i file ricorsivamente da questa cartella e sottocartelle
                $allFiles = $this->collectAllFilesRecursively($node, $extensions, $node->getName());

                // NUOVA LOGICA:
                // - Se la cartella contiene più di 1 file, mostrarla come cartella
                // - Se la cartella contiene esattamente 1 file, mostrare direttamente il file (non la cartella)
                if (count($allFiles) > 1) {
                    // Più di un file: mostra la cartella
                    $folders[] = [
                        'id' => $node->getId(),
                        'name' => $node->getName(),
                        'path' => '/' . $node->getName(),
                        'type' => 'folder',
                        'files' => $allFiles,
                        'folders' => [] // Nessuna sottocartella nella visualizzazione flat
                    ];
                } elseif (count($allFiles) === 1) {
                    // Esattamente un file: mostra direttamente il file
                    $files[] = $allFiles[0];
                }
                // Se count($allFiles) === 0, non fare nulla (cartella vuota ignorata)
            } elseif ($node instanceof \OCP\Files\File) {
                // File nella root della cartella di inizio
                $extension = strtolower(pathinfo($node->getName(), PATHINFO_EXTENSION));

                if (in_array($extension, $extensions)) {
                    $files[] = [
                        'id' => $node->getId(),
                        'name' => $node->getName(),
                        'path' => '/' . $node->getName(),
                        'size' => $node->getSize(),
                        'mimeType' => $node->getMimeType(),
                        'modifiedTime' => $node->getMTime(),
                        'type' => 'file'
                    ];
                }
            }
        }

        return [
            'folders' => $folders,
            'files' => $files
        ];
    }

    /**
     * Raccoglie ricorsivamente tutti i file musicali da una cartella e tutte le sue sottocartelle
     *
     * @param \OCP\Files\Folder $folder The folder to scan recursively
     * @param array $extensions Array of supported file extensions
     * @param string $basePath Base path for building file paths
     * @return array Array of file information arrays
     */
    private function collectAllFilesRecursively(\OCP\Files\Folder $folder, array $extensions, string $basePath = ''): array {
        $allFiles = [];

        foreach ($folder->getDirectoryListing() as $node) {
            if ($node instanceof \OCP\Files\Folder) {
                // Ricorsione nelle sottocartelle
                $subFiles = $this->collectAllFilesRecursively($node, $extensions, $basePath . '/' . $node->getName());
                $allFiles = array_merge($allFiles, $subFiles);
            } elseif ($node instanceof \OCP\Files\File) {
                $extension = strtolower(pathinfo($node->getName(), PATHINFO_EXTENSION));

                if (in_array($extension, $extensions)) {
                    $relativePath = $basePath . '/' . $node->getName();
                    $allFiles[] = [
                        'id' => $node->getId(),
                        'name' => $node->getName(),
                        'path' => $relativePath,
                        'size' => $node->getSize(),
                        'mimeType' => $node->getMimeType(),
                        'modifiedTime' => $node->getMTime(),
                        'type' => 'file'
                    ];
                }
            }
        }

        return $allFiles;
    }

    /**
     * @NoAdminRequired
     */
    public function createShare(int $fileId): DataResponse {
        // Check authentication
        if ($this->userId === null) {
            return new DataResponse(['error' => 'User not logged in'], Http::STATUS_UNAUTHORIZED);
        }

        // Validate fileId
        if ($fileId <= 0) {
            return new DataResponse(['error' => 'Invalid file ID'], Http::STATUS_BAD_REQUEST);
        }

        try {

            $userFolder = $this->rootFolder->getUserFolder($this->userId);
            $files = $userFolder->getById($fileId);

            if (count($files) === 0) {
                return new DataResponse(['error' => 'File not found'], Http::STATUS_NOT_FOUND);
            }

            $file = $files[0];

            if (!($file instanceof \OCP\Files\File)) {
                return new DataResponse(['error' => 'Not a file'], Http::STATUS_BAD_REQUEST);
            }

            // Check if a public share already exists for this file
            $existingShares = $this->shareManager->getSharesBy($this->userId, \OCP\Share\IShare::TYPE_LINK, $file, false, -1, 0);

            if (count($existingShares) > 0) {
                // Return existing share
                $share = $existingShares[0];
                $token = $share->getToken();
            } else {
                // Create new public share
                $share = $this->shareManager->newShare();
                $share->setNode($file);
                $share->setShareType(\OCP\Share\IShare::TYPE_LINK);
                $share->setSharedBy($this->userId);
                $share->setPermissions(\OCP\Constants::PERMISSION_READ);

                $share = $this->shareManager->createShare($share);
                $token = $share->getToken();
            }

            // Generate public URL
            $publicUrl = $this->urlGenerator->linkToRouteAbsolute('mxml-scores.public.showShare', ['token' => $token]);

            return new DataResponse([
                'token' => $token,
                'url' => $publicUrl
            ]);

        } catch (NotFoundException $e) {
            return new DataResponse(['error' => 'File not found'], Http::STATUS_NOT_FOUND);
        } catch (\Exception $e) {
            \OC::$server->getLogger()->error('Error in createShare: ' . $e->getMessage(), ['app' => 'mxml-scores']);
            return new DataResponse(['error' => 'Failed to create share'], Http::STATUS_INTERNAL_SERVER_ERROR);
        }
    }
}
