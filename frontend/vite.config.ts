import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src") // <--- ini bikin @ jadi src/
    }
  },
  server: {
    host: "0.0.0.0",
    port: 8080,
    hmr: {
      host: "103.160.37.103", // IP publik / domain kamu
      protocol: "ws",
      port: 8080
    }
  }
});

