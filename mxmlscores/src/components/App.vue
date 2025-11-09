<template>
	<NcContent app-name="mxmlscores" :class="{'public-share-view': isPublicShare}">
		<NcAppNavigation v-if="!isPublicShare">
			<!-- Search box in header with counter -->
			<template #search>
				<div class="search-box-wrapper">
					<NcTextField
						v-model="searchQuery"
						:label="t('scores', 'Search scores')"
						:placeholder="t('scores', 'Search scores...')"
						trailing-button-icon="close"
						:show-trailing-button="searchQuery !== ''"
						@trailing-button-click="searchQuery = ''"
						class="app-navigation-search">
						<Magnify :size="20" />
					</NcTextField>
					<NcCounterBubble v-if="totalScoresCount > 0" :count="totalScoresCount" class="search-counter-overlay" />
				</div>
			</template>

			<!-- Folder/File list -->
			<template #list>
				<!-- Skeleton screen during initial loading -->
				<template v-if="loading && folderStructure.folders.length === 0 && folderStructure.files.length === 0">
					<ul class="app-navigation-list">
						<li v-for="i in 8" :key="'skeleton-' + i" class="skeleton-item">
							<div class="skeleton-icon"></div>
							<div class="skeleton-text"></div>
						</li>
					</ul>
				</template>

				<ul v-else class="app-navigation-list">
						<li v-if="filteredFolders.length === 0 && filteredFiles.length === 0" class="empty-list">
							<span class="icon-music"></span>
							<p v-if="folderStructure.folders.length === 0 && folderStructure.files.length === 0">No music files found</p>
							<p v-else>No matches found</p>
						</li>

						<!-- Folders (visualizzazione flat - solo primo livello) -->
						<NcAppNavigationItem
							v-for="folder in filteredFolders"
							:key="'folder-' + folder.id"
							:name="folder.name"
							:open="expandedFolders.has(folder.id)"
							class="folder-item"
							@update:open="toggleFolder(folder.id)"
							@click="toggleFolder(folder.id)">
							<template #icon>
								<Folder :size="20" />
							</template>
							<template #counter>
								<NcCounterBubble :count="folder.files?.length || 0" />
							</template>

							<!-- Files in folder (inclusi quelli nelle sottocartelle) -->
							<!-- Files will be shown as children -->
								<NcAppNavigationItem
									v-if="expandedFolders.has(folder.id)" v-for="file in folder.files"
									:key="'file-' + file.id"
									:name="formatFileNameForDisplay(file.name, true)"
									:active="currentFile && currentFile.id === file.id"
									class="file-in-folder"
									:title="getFileNameWithoutExtension(file.name)"
									@click.stop="loadFile(file.id)">
								</NcAppNavigationItem>
							
						</NcAppNavigationItem>

						<!-- Files at root level (if any) -->
						<NcAppNavigationItem
							v-for="file in filteredFiles"
							:key="'rootfile-' + file.id"
							:name="getFileNameWithoutExtension(file.name)"
							:active="currentFile && currentFile.id === file.id"
							class="file-item"
							@click="loadFile(file.id)">
						</NcAppNavigationItem>
					</ul>
				</template>

				<!-- Settings button in footer -->
				<template #footer>
					<NcAppNavigationItem
						v-if="!isAdmin"
						:name="t('scores', 'Scores Folders')"
						:title="t('scores', 'Scores Folders')"
						@click="showWelcomeInfo">
						<template #icon>
							<Cog :size="20" />
						</template>
					</NcAppNavigationItem>
					<NcAppNavigationItem
						v-else
						:name="t('scores', 'Scores Folders')"
						:title="t('scores', 'Scores Folders')"
						@click="openSettingsModal">
						<template #icon>
							<Cog :size="20" />
						</template>
					</NcAppNavigationItem>
				</template>
			</NcAppNavigation>

			<!-- Main content -->
			<NcAppContent class="app-content-vue">
				<!-- Empty state when no file selected -->
				<NcEmptyContent v-if="!currentFile && !loading"
					:name="t('scores', 'Welcome to Scores')"
					:description="t('scores', 'Select a music score from the sidebar to begin')">
					<template #action>
						<div class="welcome-info-container">
							<div class="quick-tips">
								<h4>{{ t('scores', 'Quick Tips') }}</h4>
								<ul>
									<li><kbd>Space</kbd> {{ t('scores', 'Play / Pause playback') }}</li>
									<li><kbd>←</kbd> <kbd>→</kbd> {{ t('scores', 'Navigate between measures') }}</li>
									<li><kbd>+</kbd> <kbd>-</kbd> {{ t('scores', 'Zoom in / out') }}</li>
									<li>{{ t('scores', 'Adjust tempo and volume in the playback bar') }}</li>
								</ul>
							</div>
							<div class="files-app-note">
								<h4>{{ t('scores', 'Upload & Share') }}</h4>
								<p>{{ t('scores', 'Use the Files app to upload new scores and manage sharing') }}</p>
							</div>
							<div class="license-info">
								<h4>{{ t('scores', 'Credits & License') }}</h4>
								<p class="license-credits">
									{{ t('scores', 'This app uses OpenSheetMusicDisplay (OSMD)') }}
									<br>
									<small>Copyright © 2019 PhonicScore</small>
								</p>
								<details class="license-details">
									<summary>{{ t('scores', 'BSD-3-Clause License') }}</summary>
									<div class="license-text">
										<p><strong>{{ t('scores', 'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:') }}</strong></p>
										<ol>
											<li>{{ t('scores', 'Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.') }}</li>
											<li>{{ t('scores', 'Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.') }}</li>
											<li>{{ t('scores', 'Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.') }}</li>
										</ol>
										<p class="license-disclaimer">
											<small>
												{{ t('scores', 'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.') }}
											</small>
										</p>
									</div>
								</details>
							</div>
						</div>
					</template>
				</NcEmptyContent>

				<!-- Settings Modal -->
				<NcModal v-if="showSettingsModal"
					:name="t('scores', 'Scores Folders')"
					@close="closeSettingsModal">
					<div class="settings-modal-content">
						<div class="settings-section">
							<label>{{ t('scores', 'Scores Folders') }}</label>

							<!-- Lista percorsi esistenti -->
							<div class="folder-paths-list">
								<div v-if="scoresFolderPaths.length === 0" class="empty-paths-hint">
									{{ t('scores', 'No paths configured. All user files will be scanned.') }}
								</div>
								<div
									v-for="(path, index) in scoresFolderPaths"
									:key="index"
									class="folder-path-item">
									<span class="icon-folder"></span>
									<span class="folder-path-text">{{ path || '/' }}</span>
									<NcButton
										type="error"
										@click="removeFolderPath(index)">
										<template #icon>
											<span class="icon-delete"></span>
										</template>
									</NcButton>
								</div>
							</div>

							<!-- Input nuovo percorso -->
							<div class="folder-input-group">
								<input
									id="scores-folder"
									v-model="newFolderPath"
									type="text"
									:placeholder="t('scores', 'e.g. Music/Scores or leave empty for root')"
									class="folder-input"
									readonly
									@click="showFolderBrowser">
								<NcButton
									@click="showFolderBrowser">
									<template #icon>
										<span class="icon-folder"></span>
									</template>
									{{ t('scores', 'Browse') }}
								</NcButton>
								<NcButton
									type="primary"
									:disabled="!canAddNewPath"
									@click="addFolderPath">
									<template #icon>
										<span class="icon-add"></span>
									</template>
									{{ t('scores', 'Add') }}
								</NcButton>
							</div>

							<p class="settings-hint">
								{{ t('scores', 'Specify the folder paths where music scores are stored (relative to each user\'s home). You can add multiple folders. If you don\'t add any path, all user files will be scanned.') }}
							</p>
							<p class="settings-hint">
								<strong>{{ t('scores', 'Display note:') }}</strong> {{ t('scores', 'The sidebar will list folders containing more than one viewable file (counting recursively including files in subfolders). If a folder contains only one score, the file will be listed directly instead of the folder.') }}
							</p>
							<div v-if="settingsSaved" class="success-message">
								<span class="icon-checkmark"></span>
								{{ t('scores', 'Settings saved successfully!') }}
							</div>
							<div v-if="settingsError" class="error-message">
								<span class="icon-error"></span>
								{{ settingsError }}
							</div>
						</div>

						<div class="modal-footer">
							<NcButton type="secondary" @click="closeSettingsModal">
								{{ t('scores', 'Cancel') }}
							</NcButton>
							<NcButton
								type="primary"
								:disabled="savingSettings"
								@click="saveScoresFolder">
								<template #icon>
									<NcLoadingIcon v-if="savingSettings" />
									<span v-else class="icon-checkmark"></span>
								</template>
								{{ t('scores', 'Save') }}
							</NcButton>
						</div>
					</div>
				</NcModal>

				<!-- Folder Browser Modal -->
				<NcModal v-if="showBrowserModal"
					:name="t('scores', 'Select Scores Folder')"
					@close="closeFolderBrowser">
					<div class="folder-browser-content">
						<!-- Breadcrumb navigation -->
						<div class="breadcrumb">
							<span class="breadcrumb-item" @click="navigateToFolder('')">
								<span class="icon-home"></span>
								{{ t('scores', 'Home') }}
							</span>
							<template v-for="(part, index) in breadcrumbParts" :key="index">
								<span class="breadcrumb-separator">/</span>
								<span class="breadcrumb-item" @click="navigateToFolder(getBreadcrumbPath(index))">
									{{ part }}
								</span>
							</template>
						</div>

						<!-- Folder list -->
						<div class="folder-list-browser">
							<div v-if="loadingFolders" class="loading-folders">
								<NcLoadingIcon :size="20" />
								{{ t('scores', 'Loading folders...') }}
							</div>
							<div v-else-if="browserFolders.length === 0" class="empty-folders">
								<span class="icon-folder"></span>
								<p>{{ t('scores', 'No folders found') }}</p>
							</div>
							<div
								v-else
								v-for="folder in browserFolders"
								:key="folder.id"
								class="browser-folder-item"
								@dblclick="navigateToFolder(folder.path)">
								<span class="icon-folder"></span>
								<span class="folder-name-browser">{{ folder.name }}</span>
								<NcButton type="tertiary" @click="selectFolder(folder.path)">
									{{ t('scores', 'Select') }}
								</NcButton>
							</div>
						</div>

						<div class="modal-footer">
							<div class="current-selection">
								<strong>{{ t('scores', 'Selected:') }}</strong>
								<span>{{ currentBrowserPath || t('scores', '(root)') }}</span>
							</div>
							<div class="modal-actions">
								<NcButton type="secondary" @click="closeFolderBrowser">
									{{ t('scores', 'Cancel') }}
								</NcButton>
								<NcButton type="primary" @click="confirmFolderSelection">
									<template #icon>
										<span class="icon-checkmark"></span>
									</template>
									{{ t('scores', 'Confirm') }}
								</NcButton>
							</div>
						</div>
					</div>
				</NcModal>

				<!-- Skeleton screen while loading -->
				<div v-else-if="loading" class="skeleton-screen">
					<div class="skeleton-header">
						<div class="skeleton-title"></div>
						<div class="skeleton-controls"></div>
					</div>
					<div class="skeleton-content">
						<div class="skeleton-sheet">
							<div class="skeleton-staff"></div>
							<div class="skeleton-staff"></div>
							<div class="skeleton-staff"></div>
						</div>
						<div class="skeleton-playback">
							<div class="skeleton-button"></div>
							<div class="skeleton-slider"></div>
							<div class="skeleton-time"></div>
						</div>
					</div>
				</div>

				<MusicViewer
					v-else-if="currentFile && currentFile.content"
					:file-content="currentFile.content"
					:file-name="currentFile.name"
					:file-id="currentFile.id"
					:force-show-welcome="showWelcomeScreen"
					@playback-state-changed="handlePlaybackStateChange"
					@welcome-closed="showWelcomeScreen = false" />
			</NcAppContent>
	</NcContent>
</template>

<script>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import axios from '@nextcloud/axios'
import { generateUrl } from '@nextcloud/router'
import { showError } from '@nextcloud/dialogs'
import { loadState } from '@nextcloud/initial-state'
import { translate as t } from '@nextcloud/l10n'

import {
	NcContent,
	NcAppNavigation,
	NcAppNavigationItem,
	NcAppContent,
	NcCounterBubble,
	NcEmptyContent,
	NcModal,
	NcLoadingIcon,
	NcButton,
	NcTextField
} from '@nextcloud/vue'

import Magnify from 'vue-material-design-icons/Magnify.vue'
import Cog from 'vue-material-design-icons/Cog.vue'
import Folder from 'vue-material-design-icons/Folder.vue'

import MusicViewer from './MusicViewer.vue'

export default {
	name: 'App',
	components: {
		MusicViewer,
		NcContent,
		NcAppNavigation,
		NcAppNavigationItem,
		NcAppContent,
		NcCounterBubble,
		NcEmptyContent,
		NcModal,
		NcLoadingIcon,
		NcButton,
		NcTextField,
		Magnify,
		Cog,
		Folder,
	},
	setup() {
		const folderStructure = ref({ folders: [], files: [] })
		const filteredFolders = ref([])
		const filteredFiles = ref([])
		const expandedFolders = ref(new Set())
		const currentFile = ref(null)
		const loading = ref(false)
		const searchQuery = ref('')
		const isPlaying = ref(false)
		const isPublicShare = ref(false)
		const showWelcomeScreen = ref(false)
		const isAdmin = ref(false)
		const scoresFolderPaths = ref([]) // Array of folder paths
		const newFolderPath = ref('') // Temporary path for adding new folders
		const savingSettings = ref(false)
		const settingsSaved = ref(false)
		const settingsError = ref('')
		const showSettingsModal = ref(false)
		const showBrowserModal = ref(false)
		const browserFolders = ref([])
		const currentBrowserPath = ref('')
		const loadingFolders = ref(false)

		// DEV: Version check for cache busting
		console.log('[DEV] App.vue loaded - version 2.2.6')

		// Check if this is a public share using Nextcloud InitialState API
		try {
			const publicShareData = loadState('mxmlscores', 'publicShare')
			console.log('✓ Public share detected via InitialState!')
			isPublicShare.value = true

			// Load file data from InitialState
			currentFile.value = {
				id: null,
				name: publicShareData.fileName,
				content: publicShareData.fileContent,
				mimeType: 'application/vnd.recordare.musicxml+xml',
				size: 0
			}
			console.log('✓ Public share file loaded:', currentFile.value.name)
		} catch (e) {
			// Not a public share - load user's file list
			console.log('ℹ️ Not a public share - normal app mode')
		}

		// DEV-ONLY: Auto-load test sample if URL contains ?testSample=1
		console.log('[DEV] Checking testSample conditions:', {
			hasWindow: typeof window !== 'undefined',
			searchParams: typeof window !== 'undefined' ? window.location.search : 'N/A',
			hasTestSample: typeof window !== 'undefined' ? window.location.search.includes('testSample=1') : false,
			isPublicShare: isPublicShare.value
		})
		if (typeof window !== 'undefined' && window.location.search.includes('testSample=1') && !isPublicShare.value) {
			console.warn('[DEV] Auto-loading test sample from URL parameter')
			console.log('[DEV] Fetching: /apps/mxmlscores/public/test-scores/sample.musicxml')
			fetch('/apps/mxmlscores/public/test-scores/sample.musicxml')
				.then(response => {
					if (!response.ok) {
						throw new Error(`HTTP ${response.status}: ${response.statusText}`)
					}
					return response.text()
				})
				.then(xmlText => {
					currentFile.value = {
						id: -1,
						name: 'Test Sample (DEV)',
						content: btoa(xmlText),
						mimeType: 'application/vnd.recordare.musicxml+xml',
						size: xmlText.length
					}
					console.log('[DEV] Test sample loaded successfully')
				})
				.catch(err => {
					console.error('[DEV] Failed to load test sample:', err)
				})
		}
		// END DEV-ONLY

		const loadFiles = async () => {
			// Skip loading file list in public share view
			if (isPublicShare.value) {
				return
			}

			try {
				loading.value = true
				const response = await axios.get(generateUrl('/apps/mxmlscores/api/files'))
				folderStructure.value = response.data
				filterFiles()
			} catch (error) {
				showError('Failed to load music files')
				console.error(error)
			} finally {
				loading.value = false
			}
		}

		const filterFiles = () => {
			const query = searchQuery.value.toLowerCase().trim()
			if (!query) {
				filteredFolders.value = folderStructure.value.folders
				filteredFiles.value = folderStructure.value.files
			} else {
				// Filter folders and files recursively
				filteredFolders.value = filterFoldersRecursive(folderStructure.value.folders, query)
				filteredFiles.value = folderStructure.value.files.filter(file =>
					file.name.toLowerCase().includes(query)
				)
			}
		}

		const filterFoldersRecursive = (folders, query) => {
			return folders.map(folder => {
				const filteredSubfolders = filterFoldersRecursive(folder.folders || [], query)
				const filteredFiles = folder.files.filter(file =>
					file.name.toLowerCase().includes(query)
				)

				// Include folder if it has matching files or subfolders
				if (filteredFiles.length > 0 || filteredSubfolders.length > 0 || folder.name.toLowerCase().includes(query)) {
					return {
						...folder,
						folders: filteredSubfolders,
						files: filteredFiles
					}
				}
				return null
			}).filter(folder => folder !== null)
		}

		const toggleFolder = (folderId) => {
			if (expandedFolders.value.has(folderId)) {
				expandedFolders.value.delete(folderId)
			} else {
				expandedFolders.value.add(folderId)
			}
			// Trigger reactivity
			expandedFolders.value = new Set(expandedFolders.value)
		}

		const getFolderFileCount = (folder) => {
			let count = folder.files.length
			folder.folders.forEach(subfolder => {
				count += getFolderFileCount(subfolder)
			})
			return count
		}

		const getTotalFileCount = () => {
			let count = filteredFiles.value.length
			filteredFolders.value.forEach(folder => {
				count += getFolderFileCount(folder)
			})
			return count
		}

		// Computed property for total scores count
		const totalScoresCount = computed(() => getTotalFileCount())

		const getFileNameWithoutExtension = (filename) => {
			// Remove common music file extensions
			// IMPORTANTE: mxml è l'estensione principale per MusicXML non compresso
			if (!filename) return ''
			return filename.toString().replace(/\.(mxml|xml|musicxml|mxl|mei|gp|gpx|gp3|gp4|gp5)$/i, '')
		}

		// Format filename for display in sidebar
		// For files in folders: truncate from the left manually to show the right part
		const formatFileNameForDisplay = (filename, isInFolder = false) => {
			const nameWithoutExt = getFileNameWithoutExtension(filename)

			if (isInFolder) {
				// For files in folders, manually truncate from left if too long
				// 284px width = approximately 36-39 characters total (including ...)
				// Use 36 chars + 3 dots = 39 total to guarantee no right truncation
				const maxLength = 36
				if (nameWithoutExt.length > maxLength) {
					// Show the last maxLength characters (right part) with ellipsis at the start
					return '...' + nameWithoutExt.slice(-maxLength)
				}
			}

			return nameWithoutExt
		}

		const loadFile = async (fileId) => {
			try {
				loading.value = true
				const response = await axios.get(generateUrl('/apps/mxmlscores/api/file/{fileId}', { fileId }))
				currentFile.value = {
					id: fileId,
					name: response.data.name,
					content: response.data.content,
					mimeType: response.data.mimeType,
					size: response.data.size
				}
			} catch (error) {
				showError('Failed to load file')
				console.error(error)
			} finally {
				loading.value = false
			}
		}

		const handlePlaybackStateChange = (playing) => {
			isPlaying.value = playing
		}

		const showWelcomeInfo = () => {
			// Mostra la Welcome screen (nessun file caricato)
			currentFile.value = null
			loading.value = false
			showWelcomeScreen.value = true
		}

		// Admin settings functions
		const checkIsAdmin = async () => {
			try {
				const response = await axios.get(generateUrl('/apps/mxmlscores/api/settings/isAdmin'))
				isAdmin.value = response.data.isAdmin
			} catch (error) {
				console.error('Failed to check admin status:', error)
			}
		}

		const loadScoresFolder = async () => {
			if (!isAdmin.value) return

			try {
				const response = await axios.get(generateUrl('/apps/mxmlscores/api/settings/folder'))
				// Support both old single path and new multiple paths
				const data = response.data
				if (Array.isArray(data.folderPaths)) {
					scoresFolderPaths.value = data.folderPaths
				} else if (data.folderPath) {
					// Backward compatibility: convert single path to array
					scoresFolderPaths.value = data.folderPath ? [data.folderPath] : []
				} else {
					scoresFolderPaths.value = []
				}
			} catch (error) {
				console.error('Failed to load scores folder setting:', error)
			}
		}

		const openSettingsModal = () => {
			showSettingsModal.value = true
			settingsSaved.value = false
			settingsError.value = ''
			newFolderPath.value = ''
		}

		const closeSettingsModal = () => {
			showSettingsModal.value = false
			settingsSaved.value = false
			settingsError.value = ''
			newFolderPath.value = ''
		}

		const canAddNewPath = computed(() => {
			// Allow adding if newFolderPath is not already in the list
			return newFolderPath.value !== null &&
				   !scoresFolderPaths.value.includes(newFolderPath.value)
		})

		const addFolderPath = () => {
			if (canAddNewPath.value) {
				scoresFolderPaths.value.push(newFolderPath.value)
				newFolderPath.value = ''
			}
		}

		const removeFolderPath = (index) => {
			scoresFolderPaths.value.splice(index, 1)
		}

		const saveScoresFolder = async () => {
			savingSettings.value = true
			settingsSaved.value = false
			settingsError.value = ''

			try {
				await axios.post(generateUrl('/apps/mxmlscores/api/settings/folder'), {
					folderPaths: scoresFolderPaths.value
				})
				settingsSaved.value = true
				// Reload files with new folder paths
				await loadFiles()
				// Hide success message and close modal after 2 seconds
				setTimeout(() => {
					settingsSaved.value = false
					closeSettingsModal()
				}, 2000)
			} catch (error) {
				settingsError.value = error.response?.data?.error || 'Failed to save settings'
				setTimeout(() => {
					settingsError.value = ''
				}, 5000)
			} finally {
				savingSettings.value = false
			}
		}

		// Folder browser functions
		const breadcrumbParts = computed(() => {
			if (!currentBrowserPath.value) return []
			return currentBrowserPath.value.split('/')
		})

		const getBreadcrumbPath = (index) => {
			return breadcrumbParts.value.slice(0, index + 1).join('/')
		}

		const showFolderBrowser = async () => {
			showBrowserModal.value = true
			currentBrowserPath.value = newFolderPath.value || ''
			await loadBrowserFolders(currentBrowserPath.value)
		}

		const closeFolderBrowser = () => {
			showBrowserModal.value = false
			browserFolders.value = []
			currentBrowserPath.value = ''
		}

		const loadBrowserFolders = async (path) => {
			loadingFolders.value = true
			try {
				const response = await axios.get(generateUrl('/apps/mxmlscores/api/settings/browse'), {
					params: { path }
				})
				browserFolders.value = response.data.folders
				currentBrowserPath.value = response.data.currentPath
			} catch (error) {
				showError('Failed to load folders')
				console.error(error)
			} finally {
				loadingFolders.value = false
			}
		}

		const navigateToFolder = async (path) => {
			await loadBrowserFolders(path)
		}

		const selectFolder = (path) => {
			currentBrowserPath.value = path
		}

		const confirmFolderSelection = () => {
			newFolderPath.value = currentBrowserPath.value
			closeFolderBrowser()
		}

		// Watch searchQuery to trigger filterFiles automatically
		watch(searchQuery, () => {
			filterFiles()
		})


		onMounted(async () => {
			// Skip admin checks and file loading in public share view
			if (!isPublicShare.value) {
				await checkIsAdmin()
				if (isAdmin.value) {
					await loadScoresFolder()
				}
				await loadFiles()
			}
		})

		return {
			folderStructure,
			filteredFolders,
			filteredFiles,
			expandedFolders,
			currentFile,
			loading,
			searchQuery,
			isPlaying,
			isPublicShare,
			showWelcomeScreen,
			isAdmin,
			scoresFolderPaths,
			newFolderPath,
			canAddNewPath,
			savingSettings,
			settingsSaved,
			settingsError,
			showSettingsModal,
			showBrowserModal,
			browserFolders,
			currentBrowserPath,
			loadingFolders,
			breadcrumbParts,
			totalScoresCount,
			loadFiles,
			loadFile,
			filterFiles,
			toggleFolder,
			showWelcomeInfo,
			openSettingsModal,
			closeSettingsModal,
			addFolderPath,
			removeFolderPath,
			saveScoresFolder,
			showFolderBrowser,
			closeFolderBrowser,
			navigateToFolder,
			selectFolder,
			confirmFolderSelection,
			getBreadcrumbPath,
			getFileNameWithoutExtension,
			formatFileNameForDisplay,
			getFolderFileCount,
			getTotalFileCount,
			handlePlaybackStateChange,
			t,  // Add translation function
		}
	},
}
</script>

<style scoped>
/* Public share view - full width without navigation */
.public-share-view {
	width: 100%;
}

/* Ensure proper layout - content should not overlap with navigation */
:deep(.app-content-wrapper) {
	position: relative;
	z-index: 1;
}

/* Search box wrapper - matches Files app width with padding */
.search-box-wrapper {
	position: relative;
	width: 100%;
	padding: 0 8px;
}

/* Counter overlay - positioned at the right edge, aligned with folder counters */
.search-counter-overlay {
	position: absolute;
	right: 12px; /* Aligned with folder counter position */
	top: 50%;
	transform: translateY(-50%);
	pointer-events: none;
	z-index: 1;
}

/* When close button is shown, keep same position */
.search-box-wrapper:has(.app-navigation-search :deep(.input-field__clear-button)) .search-counter-overlay {
	right: 12px; /* Keep aligned with folder counters */
}

/* App navigation list */
.app-navigation-list {
	padding: 0;
	margin: 0;
	list-style: none;
}

/* Skeleton screen animation */
@keyframes skeleton-pulse {
	0%, 100% {
		opacity: 1;
	}
	50% {
		opacity: 0.4;
	}
}

.skeleton-item {
	display: flex;
	align-items: center;
	padding: 8px 16px;
	gap: 12px;
}

.skeleton-icon {
	width: 32px;
	height: 32px;
	border-radius: 4px;
	background-color: var(--color-background-dark);
	animation: skeleton-pulse 1.5s ease-in-out infinite;
}

.skeleton-text {
	flex: 1;
	height: 16px;
	border-radius: 4px;
	background-color: var(--color-background-dark);
	animation: skeleton-pulse 1.5s ease-in-out infinite;
	animation-delay: 0.15s;
}

/* Truncate long names with ellipsis */
/* Default: ellipsis at end (for folders and root-level files) */
:deep(.app-navigation-entry__name) {
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	direction: ltr;
	text-align: left;
}

/* Hide icon space for file items - multiple selectors to ensure it works */
:deep(.file-in-folder .app-navigation-entry-icon),
:deep(.file-in-folder .app-navigation-entry__icon),
:deep(.file-in-folder div.app-navigation-entry-icon),
:deep(.file-in-folder div.app-navigation-entry__icon) {
	display: none !important;
	width: 0 !important;
	min-width: 0 !important;
	max-width: 0 !important;
	margin: 0 !important;
	padding: 0 !important;
	flex: 0 0 0 !important;
}

/* For files in folders: make span take full width, no CSS ellipsis (handled by JS) */
:deep(.file-in-folder .app-navigation-entry__name),
:deep(.file-in-folder .app-navigation-entry-link__name),
:deep(.file-in-folder .app-navigation-entry__title),
:deep(.app-navigation-entry__children .app-navigation-entry .app-navigation-entry__name),
:deep(.app-navigation-entry__children .app-navigation-entry .app-navigation-entry__title),
:deep(.app-navigation-entry__children .app-navigation-entry-link__name) {
	flex: 1 1 auto !important;
	width: 100% !important;
	max-width: none !important;
	min-width: 0 !important;
	white-space: nowrap !important;
	overflow: visible !important;
	text-overflow: clip !important;
	direction: ltr !important;
	text-align: left !important;
}

.empty-list {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 32px 16px;
	text-align: center;
	color: var(--color-text-maxcontrast);
}

.empty-list .icon-music {
	font-size: 48px;
	opacity: 0.3;
	margin-bottom: 16px;
}

/* Main content */
.empty-content,
.loading-content {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 100%;
	padding: 3rem;
	text-align: center;
}

.empty-icon {
	width: 80px;
	height: 80px;
	border-radius: 50%;
	background-color: var(--color-background-hover);
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 1.5rem;
}

.empty-icon .icon-music {
	font-size: 40px;
	opacity: 0.5;
}

.empty-content h2 {
	margin-bottom: 0.5rem;
	font-size: 24px;
	color: var(--color-main-text);
}

.empty-content p {
	color: var(--color-text-maxcontrast);
	margin-bottom: 0;
}

.quick-tips {
	background-color: var(--color-background-hover);
	padding: 20px;
	border-radius: 8px;
	width: 100%;
	max-width: 400px;
	text-align: left;
}

.quick-tips h4 {
	margin: 0 0 12px 0;
	font-size: 16px;
}

.quick-tips ul {
	list-style: none;
	padding: 0;
	margin: 0;
}

.quick-tips li {
	padding: 6px 0;
	color: var(--color-text-maxcontrast);
}

.quick-tips kbd {
	background-color: var(--color-main-background);
	border: 1px solid var(--color-border);
	border-radius: 3px;
	padding: 2px 6px;
	font-family: 'SF Mono', 'Monaco', monospace;
	font-size: 12px;
	font-weight: 600;
	color: var(--color-primary-element);
	margin: 0 2px;
}

/* Welcome info container */
.welcome-info-container {
	display: flex;
	flex-direction: column;
	gap: 20px;
	align-items: center;
	max-height: none !important;
	overflow-y: auto;
	padding-bottom: 40px;
}

/* Files app note - matches quick-tips style */
.files-app-note {
	background-color: var(--color-background-hover);
	border-radius: 8px;
	padding: 20px;
	width: 100%;
	max-width: 400px;
	text-align: left;
}

.files-app-note h4 {
	margin: 0 0 12px 0;
	font-size: 15px;
	font-weight: 600;
	color: var(--color-main-text);
}

.files-app-note p {
	margin: 0;
	font-size: 14px;
	line-height: 1.6;
	color: var(--color-text-maxcontrast);
}

/* License info - matches other sections style */
.license-info {
	background-color: var(--color-background-hover);
	border-radius: 8px;
	padding: 20px;
	width: 100%;
	max-width: 400px;
	text-align: left;
}

.license-info h4 {
	margin: 0 0 12px 0;
	font-size: 15px;
	font-weight: 600;
	color: var(--color-main-text);
}

.license-credits {
	margin: 0;
	font-size: 14px;
	line-height: 1.6;
	color: var(--color-text-maxcontrast);
}

.license-credits small {
	font-size: 12px;
	color: var(--color-text-maxcontrast);
	opacity: 0.8;
}

.license-details {
	margin-top: 0;
}

.license-details summary {
	cursor: pointer;
	font-size: 13px;
	font-weight: 500;
	color: var(--color-primary-element);
	padding: 8px 0;
	user-select: none;
}

.license-details summary:hover {
	text-decoration: underline;
}

.license-text {
	margin-top: 12px;
	padding: 12px;
	background-color: var(--color-background-dark);
	border-radius: 4px;
	font-size: 12px;
	line-height: 1.5;
	color: var(--color-text-maxcontrast);
}

.license-text p {
	margin: 0 0 8px 0;
}

.license-text ol {
	margin: 8px 0;
	padding-left: 20px;
}

.license-text li {
	margin: 6px 0;
}

.license-disclaimer {
	margin-top: 12px;
	padding-top: 12px;
	border-top: 1px solid var(--color-border);
	font-style: italic;
}

/* Admin Settings Button */
.admin-settings-button {
	margin: 24px 0;
}

.configure-button {
	padding: 14px 28px;
	border: none;
	border-radius: var(--border-radius-large);
	font-weight: 600;
	font-size: 15px;
	cursor: pointer;
	transition: all 0.2s ease;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.configure-button.primary {
	background-color: var(--color-primary-element);
	color: var(--color-primary-text);
}

.configure-button.primary:hover {
	background-color: var(--color-primary-element-hover);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.configure-button.secondary {
	background-color: var(--color-background-dark);
	color: var(--color-main-text);
	border: 2px solid var(--color-border-dark);
}

.configure-button.secondary:hover {
	background-color: var(--color-background-hover);
	border-color: var(--color-primary-element);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* Settings Modal */
.settings-modal {
	background-color: var(--color-main-background);
	border-radius: var(--border-radius-large);
	box-shadow: 0 16px 48px rgba(0, 0, 0, 0.3);
	width: 90%;
	max-width: 600px;
	max-height: 85vh;
	display: flex;
	flex-direction: column;
	animation: slideUp 0.3s ease-out;
}

.settings-modal .modal-header h3 {
	margin: 0;
	font-size: 20px;
	display: flex;
	align-items: center;
	gap: 10px;
	color: var(--color-primary-element);
}

.settings-section {
	margin-bottom: 16px;
}

.settings-section label {
	display: block;
	margin-bottom: 8px;
	font-weight: 500;
	color: var(--color-main-text);
}

.folder-input-group {
	display: flex;
	gap: 8px;
	margin-bottom: 8px;
}

.folder-input {
	flex: 1;
	padding: 10px 12px;
	border: 1px solid var(--color-border);
	border-radius: 6px;
	font-size: 14px;
	background-color: var(--color-main-background);
	color: var(--color-main-text);
}

.folder-input:focus {
	outline: none;
	border-color: var(--color-primary-element);
}

.save-button {
	padding: 10px 20px;
	background-color: var(--color-primary-element);
	color: var(--color-primary-text);
	border: none;
	border-radius: 6px;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s;
	display: flex;
	align-items: center;
	gap: 8px;
}

.save-button:hover:not(:disabled) {
	background-color: var(--color-primary-element-hover);
	transform: translateY(-1px);
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.save-button:disabled {
	opacity: 0.6;
	cursor: not-allowed;
}

.browse-button {
	padding: 10px 16px;
	background-color: var(--color-background-dark);
	color: var(--color-main-text);
	border: 1px solid var(--color-border);
	border-radius: 6px;
	font-weight: 600;
	cursor: pointer;
	transition: all 0.2s;
	display: flex;
	align-items: center;
	gap: 6px;
}

.browse-button:hover {
	background-color: var(--color-background-hover);
	transform: translateY(-1px);
}

.settings-hint {
	font-size: 13px;
	color: var(--color-text-maxcontrast);
	margin: 4px 0;
}

.success-message {
	padding: 12px;
	background-color: var(--color-success);
	color: white;
	border-radius: 6px;
	display: flex;
	align-items: center;
	gap: 8px;
	margin-top: 12px;
	animation: slideIn 0.3s ease-out;
}

.error-message {
	padding: 12px;
	background-color: var(--color-error);
	color: white;
	border-radius: 6px;
	display: flex;
	align-items: center;
	gap: 8px;
	margin-top: 12px;
	animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
	from {
		opacity: 0;
		transform: translateY(-10px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

/* Modal Backdrop & Animations */
.modal-backdrop {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.6);
	backdrop-filter: blur(2px);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 10000;
	animation: fadeIn 0.25s ease-out;
	padding: 20px;
}

@keyframes fadeIn {
	from {
		opacity: 0;
		backdrop-filter: blur(0);
	}
	to {
		opacity: 1;
		backdrop-filter: blur(2px);
	}
}

@keyframes slideUp {
	from {
		opacity: 0;
		transform: translateY(30px) scale(0.95);
	}
	to {
		opacity: 1;
		transform: translateY(0) scale(1);
	}
}

/* Folder Browser Modal */
.folder-browser-modal {
	background-color: var(--color-main-background);
	border-radius: var(--border-radius-large);
	box-shadow: 0 16px 48px rgba(0, 0, 0, 0.3);
	width: 90%;
	max-width: 750px;
	max-height: 85vh;
	display: flex;
	flex-direction: column;
	animation: slideUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

/* Modal Header */
.modal-header {
	padding: 24px;
	border-bottom: 2px solid var(--color-border);
	display: flex;
	align-items: center;
	justify-content: space-between;
	background: linear-gradient(135deg, var(--color-primary-element-light) 0%, transparent 100%);
}

.modal-header h3 {
	margin: 0;
	font-size: 22px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 12px;
	color: var(--color-primary-element);
}

.close-button {
	background: var(--color-background-hover);
	border: none;
	cursor: pointer;
	padding: 10px;
	border-radius: var(--border-radius);
	transition: all 0.2s ease;
	color: var(--color-main-text);
	width: 40px;
	height: 40px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.close-button:hover {
	background-color: var(--color-error);
	color: white;
	transform: rotate(90deg);
}

.close-button .icon-close {
	font-size: 18px;
}

.modal-body {
	flex: 1;
	overflow-y: auto;
	padding: 28px;
	background-color: var(--color-main-background);
}

.breadcrumb {
	display: flex;
	align-items: center;
	flex-wrap: wrap;
	gap: 6px;
	padding: 14px 16px;
	background: linear-gradient(to right, var(--color-background-hover) 0%, var(--color-main-background) 100%);
	border: 2px solid var(--color-border);
	border-radius: var(--border-radius);
	margin-bottom: 20px;
	font-size: 14px;
	box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.05);
}

.breadcrumb-item {
	cursor: pointer;
	padding: 6px 12px;
	border-radius: var(--border-radius);
	transition: all 0.2s ease;
	display: flex;
	align-items: center;
	gap: 6px;
	color: var(--color-primary-element);
	font-weight: 500;
}

.breadcrumb-item:hover {
	background-color: var(--color-primary-element-light);
	transform: scale(1.05);
}

.breadcrumb-item:active {
	transform: scale(0.98);
}

.breadcrumb-item .icon-home {
	font-size: 16px;
}

.breadcrumb-separator {
	color: var(--color-text-maxcontrast);
	user-select: none;
	font-weight: 300;
}

.folder-list-browser {
	min-height: 320px;
	max-height: 420px;
	overflow-y: auto;
	border: 2px solid var(--color-border);
	border-radius: var(--border-radius);
	padding: 12px;
	background-color: var(--color-background-hover);
}

.folder-list-browser::-webkit-scrollbar {
	width: 12px;
}

.folder-list-browser::-webkit-scrollbar-track {
	background: var(--color-main-background);
	border-radius: var(--border-radius);
}

.folder-list-browser::-webkit-scrollbar-thumb {
	background: var(--color-primary-element);
	border-radius: var(--border-radius);
}

.folder-list-browser::-webkit-scrollbar-thumb:hover {
	background: var(--color-primary-element-hover);
}

.loading-folders,
.empty-folders {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 60px 20px;
	color: var(--color-text-maxcontrast);
	gap: 16px;
}

.loading-folders .icon-loading {
	font-size: 40px;
	color: var(--color-primary-element);
}

.empty-folders .icon-folder {
	font-size: 56px;
	opacity: 0.25;
}

.browser-folder-item {
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 14px 16px;
	border-radius: var(--border-radius);
	cursor: pointer;
	transition: all 0.2s ease;
	margin-bottom: 6px;
	background-color: var(--color-main-background);
	border: 2px solid transparent;
}

.browser-folder-item:hover {
	background-color: var(--color-background-hover);
	border-color: var(--color-primary-element-light);
	transform: translateX(4px);
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.browser-folder-item .icon-folder {
	font-size: 28px;
	color: var(--color-primary-element);
	opacity: 0.9;
	flex-shrink: 0;
}

.folder-name-browser {
	flex: 1;
	font-weight: 500;
	font-size: 15px;
	color: var(--color-main-text);
}

.select-folder-button {
	padding: 8px 18px;
	background-color: var(--color-primary-element-light);
	color: var(--color-primary-element);
	border: 2px solid var(--color-primary-element);
	border-radius: var(--border-radius);
	cursor: pointer;
	font-weight: 600;
	font-size: 13px;
	transition: all 0.25s ease;
	opacity: 0;
	transform: scale(0.9);
}

.browser-folder-item:hover .select-folder-button {
	opacity: 1;
	transform: scale(1);
}

.select-folder-button:hover {
	background-color: var(--color-primary-element);
	color: white;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
	transform: scale(1.05);
}

.select-folder-button:active {
	transform: scale(0.95);
}

.modal-footer {
	padding: 20px 24px;
	border-top: 2px solid var(--color-border);
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 20px;
	background: linear-gradient(to top, var(--color-background-hover) 0%, transparent 100%);
}

.current-selection {
	flex: 1;
	font-size: 14px;
	color: var(--color-text-maxcontrast);
	padding: 10px 14px;
	background-color: var(--color-background-dark);
	border-radius: var(--border-radius);
	border-left: 3px solid var(--color-primary-element);
}

.current-selection strong {
	color: var(--color-main-text);
	margin-right: 8px;
	font-weight: 600;
}

.current-selection span {
	color: var(--color-primary-element);
	font-weight: 500;
}

.modal-actions {
	display: flex;
	gap: 10px;
}

.secondary-button,
.primary-button {
	padding: 12px 24px;
	border: none;
	border-radius: var(--border-radius);
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	transition: all 0.2s ease;
	display: flex;
	align-items: center;
	gap: 8px;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.secondary-button {
	background-color: var(--color-background-dark);
	color: var(--color-main-text);
	border: 2px solid var(--color-border);
}

.secondary-button:hover {
	background-color: var(--color-background-hover);
	border-color: var(--color-border-dark);
	transform: translateY(-2px);
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
}

.primary-button {
	background-color: var(--color-primary-element);
	color: var(--color-primary-text);
}

.primary-button:hover:not(:disabled) {
	background-color: var(--color-primary-element-hover);
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.primary-button:disabled {
	opacity: 0.6;
	cursor: not-allowed;
	transform: none;
}

.primary-button:active:not(:disabled),
.secondary-button:active {
	transform: translateY(0);
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.loading-spinner {
	width: 60px;
	height: 60px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.loading-spinner .icon-loading {
	font-size: 40px;
}

.loading-content p {
	margin-top: 1rem;
	color: var(--color-text-maxcontrast);
}

/* Skeleton Screen Styles */
.skeleton-screen {
	width: 100%;
	height: 100%;
	padding: 2rem;
	animation: pulse 2s infinite;
}

@keyframes pulse {
	0%, 100% {
		opacity: 1;
	}
	50% {
		opacity: 0.85;
	}
}

.skeleton-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 2rem;
	padding: 1rem;
	background: var(--color-background-dark);
	border-radius: var(--border-radius);
}

.skeleton-title {
	width: 200px;
	height: 32px;
	background: linear-gradient(90deg, 
		var(--color-background-hover) 0%, 
		var(--color-background-dark) 50%, 
		var(--color-background-hover) 100%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: var(--border-radius);
}

.skeleton-controls {
	display: flex;
	gap: 1rem;
}

.skeleton-controls::before,
.skeleton-controls::after {
	content: '';
	width: 100px;
	height: 32px;
	background: linear-gradient(90deg, 
		var(--color-background-hover) 0%, 
		var(--color-background-dark) 50%, 
		var(--color-background-hover) 100%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: var(--border-radius);
}

.skeleton-content {
	display: flex;
	flex-direction: column;
	gap: 2rem;
}

.skeleton-sheet {
	width: 100%;
	max-width: 900px;
	margin: 0 auto;
	padding: 2rem;
	background: var(--color-main-background);
	border: 1px solid var(--color-border);
	border-radius: var(--border-radius-large);
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.skeleton-staff {
	width: 100%;
	height: 80px;
	margin-bottom: 1.5rem;
	background: repeating-linear-gradient(
		180deg,
		transparent,
		transparent 14px,
		var(--color-border) 14px,
		var(--color-border) 16px
	);
	position: relative;
}

.skeleton-staff::before {
	content: '';
	position: absolute;
	top: 20%;
	left: 5%;
	width: 90%;
	height: 60%;
	background: linear-gradient(90deg, 
		transparent 0%, 
		var(--color-background-hover) 20%, 
		var(--color-background-hover) 40%, 
		transparent 60%);
	background-size: 200% 100%;
	animation: shimmer 2s infinite;
}

.skeleton-playback {
	display: flex;
	align-items: center;
	gap: 2rem;
	padding: 1.5rem;
	background: var(--color-background-hover);
	border-radius: var(--border-radius-large);
	max-width: 900px;
	margin: 0 auto;
}

.skeleton-button {
	width: 44px;
	height: 44px;
	background: linear-gradient(90deg, 
		var(--color-background-dark) 0%, 
		var(--color-border) 50%, 
		var(--color-background-dark) 100%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: 50%;
}

.skeleton-slider {
	flex: 1;
	height: 32px;
	background: linear-gradient(90deg, 
		var(--color-background-dark) 0%, 
		var(--color-border) 50%, 
		var(--color-background-dark) 100%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: var(--border-radius);
}

.skeleton-time {
	width: 80px;
	height: 24px;
	background: linear-gradient(90deg, 
		var(--color-background-dark) 0%, 
		var(--color-border) 50%, 
		var(--color-background-dark) 100%);
	background-size: 200% 100%;
	animation: shimmer 1.5s infinite;
	border-radius: var(--border-radius);
}

@keyframes shimmer {
	0% {
		background-position: -200% 0;
	}
	100% {
		background-position: 200% 0;
	}
}

/* Ensure app-content-vue compliance */
.app-content-vue {
	position: relative;
	min-height: 100%;
	display: flex;
	flex-direction: column;
}

/* Settings Modal Content Styles */
.settings-modal-content,
.folder-browser-content {
	padding: 20px;
	min-height: 400px;
}

.settings-section {
	margin-bottom: 20px;
}

.settings-section label {
	display: block;
	margin-bottom: 8px;
	font-weight: 600;
	color: var(--color-main-text);
}

.folder-input-group {
	display: flex;
	gap: 10px;
	margin-bottom: 12px;
}

.folder-input {
	flex: 1;
	padding: 8px 12px;
	border: 2px solid var(--color-border);
	border-radius: var(--border-radius);
	background: var(--color-main-background);
	color: var(--color-main-text);
	font-size: 14px;
	cursor: pointer;
}

.folder-paths-list {
	margin-bottom: 16px;
	padding: 12px;
	background: var(--color-background-hover);
	border-radius: var(--border-radius);
	min-height: 60px;
	max-height: 200px;
	overflow-y: auto;
}

.empty-paths-hint {
	color: var(--color-text-maxcontrast);
	font-size: 14px;
	font-style: italic;
	text-align: center;
	padding: 20px 10px;
}

.folder-path-item {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 8px 12px;
	margin-bottom: 8px;
	background: var(--color-main-background);
	border: 1px solid var(--color-border);
	border-radius: var(--border-radius);
}

.folder-path-item:last-child {
	margin-bottom: 0;
}

.folder-path-item .icon-folder {
	flex-shrink: 0;
	color: var(--color-text-maxcontrast);
}

.folder-path-text {
	flex: 1;
	font-size: 14px;
	color: var(--color-main-text);
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.folder-input:hover {
	border-color: var(--color-primary-element);
}

.settings-hint {
	font-size: 13px;
	color: var(--color-text-maxcontrast);
	line-height: 1.5;
	margin: 8px 0;
}

.success-message,
.error-message {
	padding: 12px;
	border-radius: var(--border-radius);
	margin: 16px 0;
	display: flex;
	align-items: center;
	gap: 8px;
}

.success-message {
	background: var(--color-success-hover);
	color: var(--color-success-text);
	border: 1px solid var(--color-success);
}

.error-message {
	background: var(--color-error-hover);
	color: var(--color-error-text);
	border: 1px solid var(--color-error);
}

/* Folder Browser Styles */
.breadcrumb {
	padding: 12px;
	background: var(--color-background-hover);
	border-radius: var(--border-radius);
	margin-bottom: 16px;
	display: flex;
	align-items: center;
	flex-wrap: wrap;
	gap: 4px;
}

.breadcrumb-item {
	padding: 4px 8px;
	border-radius: var(--border-radius);
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 4px;
	transition: background 0.2s;
}

.breadcrumb-item:hover {
	background: var(--color-background-dark);
}

.breadcrumb-separator {
	color: var(--color-text-maxcontrast);
	margin: 0 4px;
}

.folder-list-browser {
	min-height: 300px;
	max-height: 400px;
	overflow-y: auto;
	border: 1px solid var(--color-border);
	border-radius: var(--border-radius);
	padding: 8px;
}

.browser-folder-item {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 8px;
	border-radius: var(--border-radius);
	cursor: pointer;
	transition: background 0.2s;
}

.browser-folder-item:hover {
	background: var(--color-background-hover);
}

.folder-name-browser {
	flex: 1;
}

.loading-folders,
.empty-folders {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 40px;
	color: var(--color-text-maxcontrast);
}

.current-selection {
	font-size: 13px;
	color: var(--color-text-maxcontrast);
}

.modal-actions {
	display: flex;
	gap: 8px;
}

</style>

<style>
/* Global styles (not scoped) for app icon - always white */
/* Apply filter to make the black icon white in all themes */
.app-menu-icon img[src*="mxmlscores/img/app.svg"] {
	filter: brightness(0) invert(1);
}

/* Remove custom toggle positioning - use Nextcloud default */

/* Force desktop layout behavior - sidebar should push content, not overlay */
/* Mobile responsiveness for welcome screen */
@media (max-width: 768px) {
	/* Allow NcEmptyContent to scroll on mobile */
	.app-content-vue :deep(.empty-content) {
		max-height: none !important;
		height: auto !important;
		overflow-y: visible !important;
	}

	.app-content-vue :deep(.empty-content__action) {
		max-height: calc(100vh - 300px) !important;
		overflow-y: auto !important;
		padding-bottom: 20px;
	}

	.welcome-info-container {
		padding: 0 16px 40px 16px;
		width: 100%;
		box-sizing: border-box;
		max-height: none !important;
	}

	.quick-tips,
	.files-app-note,
	.license-info {
		max-width: 100%;
		width: 100%;
	}

	.license-info {
		font-size: 13px;
	}

	.license-text {
		font-size: 11px;
	}

	.license-details summary {
		font-size: 12px;
	}
}

@media (min-width: 1024px) {
	/* When navigation is open, ensure content has proper margin */
	#content-vue:not(.app-navigation-hidden) #app-content-vue {
		margin-left: 300px;
		transition: margin-left 0.3s ease;
	}

	/* When navigation is hidden, content should be full width */
	#content-vue.app-navigation-hidden #app-content-vue {
		margin-left: 0;
		transition: margin-left 0.3s ease;
	}
}

/* Playback controls are now elastic (width: 100%) and will automatically adapt to container width */

</style>

<style>
/* Global styles - not scoped - to override Nextcloud defaults */

/* Prevent double scrollbar - only MusicViewer should scroll */
#app-content-vue {
	overflow: hidden !important;
	height: 100vh;
}

.app-content-vue {
	overflow: hidden !important;
	height: 100vh;
}

/* Override the CSS variable that controls child item indentation for folder contents */
/* Using multiple selectors and high specificity to override Nextcloud's default */
li.app-navigation-entry.folder-item .app-navigation-entry__children,
.app-navigation-list li.folder-item .app-navigation-entry__children,
ul li.folder-item .app-navigation-entry__children {
	--app-navigation-item-child-offset: 0px !important;
	padding-inline-start: 0 !important;
	padding-inline-end: 0 !important;
	padding-left: 0 !important;
	padding-right: 0 !important;
}

/* HIDE ICON SPACE FOR ALL FILE ITEMS (both in folders and root) */
li.file-in-folder .app-navigation-entry-icon,
li.file-in-folder div.app-navigation-entry-icon,
li.file-in-folder .app-navigation-entry__icon,
li.file-in-folder div.app-navigation-entry__icon,
li.file-item .app-navigation-entry-icon,
li.file-item div.app-navigation-entry-icon,
li.file-item .app-navigation-entry__icon,
li.file-item div.app-navigation-entry__icon {
	display: none !important;
	width: 0 !important;
	min-width: 0 !important;
	max-width: 0 !important;
	margin: 0 !important;
	padding: 0 !important;
	flex: 0 0 0 !important;
	visibility: hidden !important;
}

/* Add minimal left padding to root level files */
li.file-item,
li.file-item > a,
li.file-item .app-navigation-entry-link {
	padding-left: 5px !important;
}

/* Remove right padding from files in folders - AGGRESSIVE targeting with wildcard */
li.file-in-folder,
li.file-in-folder *,
li.file-in-folder > *,
li.file-in-folder > a,
li.file-in-folder > a *,
li.file-in-folder .app-navigation-entry-link,
li.file-in-folder .app-navigation-entry__name,
li.file-in-folder .app-navigation-entry-link__name,
li.file-in-folder a,
li.file-in-folder span,
li.file-in-folder div,
li[class*="file-in-folder"],
li[class*="file-in-folder"] *,
li[class*="file-in-folder"] > a,
li[class*="file-in-folder"] span {
	padding-right: 0 !important;
	padding-inline-end: 0 !important;
	padding-inline-start: 0 !important;
	margin-right: 0 !important;
	margin-inline-end: 0 !important;
}

/* ULTRA SPECIFIC override for the link inside file items in folders - maximum CSS specificity */
.app-navigation ul.app-navigation-list li.file-in-folder.app-navigation-entry:not(.app-navigation-entry--editing) > a.app-navigation-entry-link,
.app-navigation .app-navigation-list li.file-in-folder.app-navigation-entry > a.app-navigation-entry-link,
ul.app-navigation-list > li.file-in-folder.app-navigation-entry:not(.app-navigation-entry--editing) .app-navigation-entry-link {
	padding-inline-end: 0 !important;
	padding-right: 0 !important;
	padding-left: 0 !important;
	padding-inline-start: 0 !important;
}

/* Extra specific targeting for Nextcloud's component structure */
li.file-in-folder .app-navigation-entry-wrapper,
li.file-in-folder .app-navigation-entry,
li.file-in-folder .app-navigation-entry__children,
li.file-in-folder [class*="app-navigation"],
li.file-in-folder [class*="entry"] {
	padding-right: 0 !important;
	padding-inline-end: 0 !important;
	padding-inline-start: 0 !important;
	margin-right: 0 !important;
	margin-inline-end: 0 !important;
}

/* REMOVED - was contradicting scoped RTL rules for truncation */
/* Let the scoped :deep() rules handle text direction for truncation */
</style>
