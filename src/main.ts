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
import { createPinia } from 'pinia'

// Plugins
import { registerPlugins } from '@/plugins'

console.log('Creating app')
const app = createApp(App)

console.log('Registering plugins')
registerPlugins(app)

console.log('Creating store')
app.use(createPinia())

console.log('Mounting app')
app.mount('#app')
