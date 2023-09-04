/**
 * main.ts
 *
 * Bootstraps Vuetify and other plugins then mounts the App`
 */

console.log('Running main.ts')

// Components
import App from './App.vue'

// Composables
import { createApp } from 'vue'

// Plugins
import { registerPlugins } from '@/plugins'

console.log('Creating app')

const app = createApp(App)

console.log('Registering plugins')

registerPlugins(app)

console.log('Mounting app')

app.mount('#app')
