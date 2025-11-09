import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export default defineConfig({
	plugins: [vue()],
	define: {
		'process.env.NODE_ENV': JSON.stringify('production'),
		'process.env': JSON.stringify({}),
		'global': 'globalThis',
	},
	build: {
		outDir: 'js',
		emptyOutDir: false,
		lib: {
			entry: path.resolve(__dirname, 'src/main.js'),
			name: 'MxmlScores',
			fileName: () => 'mxml-scores-main.js',
			formats: ['iife'],
		},
		rollupOptions: {
			external: [],
			output: {
				assetFileNames: (assetInfo) => {
					if (assetInfo.name === 'style.css') {
						return 'main.css'
					}
					return assetInfo.name
				},
				entryFileNames: 'mxml-scores-main.js',
				globals: {},
			},
		},
		cssCodeSplit: false,
		commonjsOptions: {
			include: [/node_modules/],
			transformMixedEsModules: true,
		},
	},
	resolve: {
		alias: {
			'@': path.resolve(__dirname, './src'),
			path: 'path-browserify',
			stream: 'stream-browserify',
			vm: 'vm-browserify',
		},
	},
})
