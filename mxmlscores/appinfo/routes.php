<?php
/**
 * Nextcloud - Scores
 *
 * Routes definition for the Scores app.
 *
 * Best practices:
 * - Use RESTful conventions (GET for read, POST for create, PUT/PATCH for update, DELETE for delete)
 * - Group related routes together with comments
 * - Use descriptive route names following the pattern: controller#method
 * - Keep URLs semantic and hierarchical
 * - Use plural nouns for collections (/api/files) and singular with ID (/api/file/{fileId})
 *
 * @see https://docs.nextcloud.com/server/stable/developer_manual/basics/routing.html
 */

return [
    'routes' => [
        // Main application page
        ['name' => 'page#index', 'url' => '/', 'verb' => 'GET'],

        // File API - retrieve and list MusicXML scores
        ['name' => 'api#getFile', 'url' => '/api/file/{fileId}', 'verb' => 'GET'],
        ['name' => 'api#listFiles', 'url' => '/api/files', 'verb' => 'GET'],

        // Sharing API - create and access public shares
        ['name' => 'api#createShare', 'url' => '/api/share/{fileId}', 'verb' => 'POST'],
        ['name' => 'public#showShare', 'url' => '/s/{token}', 'verb' => 'GET'],

        // Admin settings API - manage scores folder configuration
        ['name' => 'settings#isAdmin', 'url' => '/api/settings/isAdmin', 'verb' => 'GET'],
        ['name' => 'settings#getScoresFolder', 'url' => '/api/settings/folder', 'verb' => 'GET'],
        ['name' => 'settings#setScoresFolder', 'url' => '/api/settings/folder', 'verb' => 'POST'],
        ['name' => 'settings#browseFolders', 'url' => '/api/settings/browse', 'verb' => 'GET'],
    ]
];
