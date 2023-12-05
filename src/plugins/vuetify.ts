/**
 * plugins/vuetify.ts
 *
 * Framework documentation: https://vuetifyjs.com`
 */

// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Composables
import { createVuetify, ThemeDefinition } from 'vuetify'
import { VDatePicker } from 'vuetify/labs/VDatePicker'

const myCustomLightTheme: ThemeDefinition = {
  dark: false,
  colors: {
  primary: "#795548",
  secondary: "#ffc107",
  accent: "#ff5722",
  error: "#e91e63",
  warning: "#ff9800",
  info: "#00bcd4",
  success: "#4caf50"
  }
};

export default createVuetify({
  components: {
    VDatePicker,
  },
  theme: {
    defaultTheme: 'myCustomLightTheme',
    themes: {
      myCustomLightTheme
    },
  },
})
