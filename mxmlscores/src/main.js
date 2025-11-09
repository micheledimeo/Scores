import { createApp } from 'vue'
import App from './components/App.vue'

// Stili globali
import './css/main.scss'

// CRITICAL: Set the app name for @nextcloud/vue BEFORE importing any components
// This prevents the "@nextcloud/vue library was used without setting appName" error
window.OCA = window.OCA || {}
window.OCA.Scores = window.OCA.Scores || {}
window.OCA.Scores.appName = 'mxmlscores'

// Also set on window for compatibility
window.appName = 'mxmlscores'

const app = createApp(App)
app.provide('appName', 'mxmlscores')
app.mount('#app')
