import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";

// SITE_URL is the canonical public origin (used for sitemaps, OG tags).
// BASE_PATH is the path the site is served under — empty for the apex
// domain stisummerschool.org, or "/<repo>" for a GitHub Pages project URL.
const SITE_URL = process.env.SITE_URL || "https://stisummerschool.org";
const BASE_PATH = process.env.BASE_PATH ?? "";

export default defineConfig({
  site: SITE_URL,
  base: BASE_PATH,
  trailingSlash: "ignore",
  // The invite page under /join/ is deliberately unlisted — keep it out of
  // the sitemap so it is not advertised to crawlers.
  integrations: [mdx(), sitemap({ filter: (page) => !page.includes("/join/") })],
});
