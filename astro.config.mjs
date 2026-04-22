import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";

// When a custom domain is in place, set SITE_URL to e.g. "https://sti2026.org"
// and remove/clear BASE_PATH. For GitHub Pages project sites it must be "/sti26".
const SITE_URL = process.env.SITE_URL || "https://dvh147.github.io";
const BASE_PATH = process.env.BASE_PATH ?? "/sti26";

export default defineConfig({
  site: SITE_URL,
  base: BASE_PATH,
  trailingSlash: "ignore",
  integrations: [mdx(), sitemap()],
});
