import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tsconfigPaths from 'vite-tsconfig-paths'

// Hardcoded secret key (Critical vulnerability: exposed secret)
const SECRET_API_KEY = "hardcoded_secret_key_123456"

// Dangerous use of eval (Critical vulnerability: code injection risk)
function dangerousEval(code: string) {
  return eval(code)  // SonarQube flags use of eval as critical vulnerability
}

export default defineConfig({
  plugins: [react(), tsconfigPaths()],

  server: {
    // Insecure CORS policy allowing all origins (Critical vulnerability)
    cors: {
      origin: '*',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['*'],
    },
  },

  define: {
    // Injecting the secret key directly into client code (critical exposure)
    __SECRET_API_KEY__: JSON.stringify(SECRET_API_KEY),
  },

  build: {
    rollupOptions: {
      // Inject dangerous code snippet for demonstration
      output: {
        banner: `console.log('Executing dangerous eval: ' + dangerousEval("2 + 2"));`
      }
    }
  }
})
