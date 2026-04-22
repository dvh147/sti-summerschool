# STI Summer School 2026 — website

Source for the website of the **11th Summer School on Data and Algorithms for
Science, Technology & Innovation Studies**, 7–9 September 2026, Valrose Castle, Nice.

Built with [Astro](https://astro.build/), deployed to GitHub Pages.

## Local development

```sh
npm install
npm run dev     # http://localhost:4321/sti26
npm run build   # outputs dist/
npm run preview # serve the built site locally
```

## Content & configuration

Most event-wide facts (dates, fee, venue, contact email, partners) live in a
single file so there's one place to update:

- `src/site.ts`

Long-form copy lives inside each page under `src/pages/`.

- `src/pages/index.astro` — home
- `src/pages/about.astro`
- `src/pages/call-for-papers.astro`
- `src/pages/program.astro` — provisional schedule (update after acceptance deadline)
- `src/pages/speakers.astro` — keynote cards
- `src/pages/registration.astro` — form + payment placeholder
- `src/pages/venue.astro`
- `src/pages/committee.astro`
- `src/pages/contact.astro`
- `src/pages/privacy.astro`

Public assets (the CfP PDF, the castle photo, favicon) live under `public/`.

## Registration form

The form submits to [Formspree](https://formspree.io/). To wire it up:

1. Create a Formspree account (EU region recommended for GDPR).
2. Create a new form, copy the form ID (the part after `/f/` in the endpoint URL).
3. Either:
   - set `PUBLIC_FORMSPREE_ID` as a GitHub Actions variable (Settings → Actions → Variables), or
   - edit `src/site.ts` and replace `formspreeId: "your-form-id-here"`.

Until this is done the form page shows a visible "Form not yet connected" warning.

## Payment placeholder

The registration page has a clearly-marked placeholder block for bank-transfer
details (SKEMA account). Replace the text in
`src/pages/registration.astro` when IBAN/BIC/payment-link details are available.

## Deployment

A GitHub Actions workflow (`.github/workflows/deploy.yml`) builds and deploys
the site to GitHub Pages on every push to `main` (and the feature branch
`claude/sti-summerschool-website-Kh7q3` for previews).

### Prerequisite: the site repo must be public

GitHub Pages is free only on public repos. Because `dvh147/sti26` is private
and contains internal organizing materials under `/2026/`, the site is
intended to live in a **separate public repo**. See "Splitting into a public
repo" below.

### First-time setup (in the public site repo)

1. **Settings → Pages → Source → GitHub Actions.**
2. Push to `main`. The `Deploy site to GitHub Pages` workflow runs
   automatically.
3. The site will be served at `https://<user>.github.io/<repo-name>/`.
4. If the repo is **not** called `sti26`, set a repo variable
   `BASE_PATH = /<repo-name>` under **Settings → Actions → Variables**.

### Splitting into a public repo

A helper script produces a clean copy of the website source — with the
private `/2026/` directory and the script itself left behind:

```sh
scripts/export-public.sh ../sti26-public-export
```

Then, on GitHub, create a new **public** repo (e.g. `dvh147/sti-summerschool`),
and from the exported directory:

```sh
cd ../sti26-public-export
git init
git add -A
git commit -m "Initial website"
git branch -M main
git remote add origin https://github.com/<you>/<new-repo>.git
git push -u origin main
```

After the first push:
- **Settings → Pages → Source: GitHub Actions**
- **Settings → Actions → Variables → `BASE_PATH = /<new-repo>`** (skip if the
  repo name is `sti26`)
- Optionally also set `PUBLIC_FORMSPREE_ID` once you have a Formspree form.

### Custom domain

When a custom domain is ready:

1. Add the domain in **Settings → Pages → Custom domain** and follow the DNS
   instructions (CNAME to `<user>.github.io.`, or A records for an apex domain).
2. Set two repo variables under **Settings → Actions → Variables**:
   - `SITE_URL` — e.g. `https://sti2026.org`
   - `BASE_PATH` — empty string (`""`)
3. Re-run the workflow. The emitted `dist/` will no longer be scoped under
   any base path.

## Source materials

Working files (meeting notes, draft emails, call-for-papers drafts, planning
spreadsheet) are kept under `2026/`. They are **not published** — only files
under `public/` and pages under `src/pages/` end up on the live site.
