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

Registrations are handled by a small **Cloudflare Worker** with a D1 (SQLite)
database — fully self-hosted, free at our volume, no third-party form service.
The Worker source lives in [`worker/`](./worker) and ships as a separate
Cloudflare deploy. See [`worker/README.md`](./worker/README.md) for the full
setup walkthrough.

To wire the site to the Worker:

1. Deploy the Worker once (instructions in `worker/README.md`). Note the URL
   it returns (e.g. `https://sti26-registration.<your-account>.workers.dev`).
2. Create a Cloudflare Turnstile site at
   [dash.cloudflare.com → Turnstile](https://dash.cloudflare.com) and copy
   the **site key**.
3. Set two GitHub Actions variables (Settings → Actions → Variables):
   - `PUBLIC_REGISTRATION_API` — the Worker URL.
   - `PUBLIC_TURNSTILE_SITE_KEY` — the Turnstile site key.

Until both are set the form page shows a visible "Form not yet connected"
warning.

Submissions are stored in D1 and viewable at
`<worker-url>/admin` (Bearer-token protected). Confirmation and
notification emails go through Resend if `RESEND_API_KEY`, `FROM_EMAIL`,
and `NOTIFY_EMAIL` are configured on the Worker.

## Payment placeholder

The registration page has a clearly-marked placeholder block for bank-transfer
details (SKEMA account). Replace the text in
`src/pages/registration.astro` when IBAN/BIC/payment-link details are available.

## Deployment

Two repos, one live site:

| Repo | Purpose | Pages enabled? |
|---|---|---|
| `dvh147/sti26` (private, this one) | Organizing materials under `/2026/` + website source | no |
| `dvh147/sti-summerschool` (public) | Mirror of the website source only | yes |

The site is published from the public repo. A GitHub Action
(`.github/workflows/sync-public.yml`) watches the private repo; whenever a
commit lands on `main` or the feature branch, it copies the website files
(everything except `/2026/`) into the public repo. The deploy workflow in
the public repo then publishes to GitHub Pages automatically.

**One-time setup to enable automatic sync:** see "Enabling automatic sync"
below. Until the secret is in place, use the manual PowerShell flow (next
section).

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

### Enabling automatic sync (one-time)

1. **Create a fine-grained Personal Access Token**
   - GitHub → Profile picture → Settings → Developer settings →
     Personal access tokens → **Fine-grained tokens** → **Generate new token**
   - Name: `sti26 sync to public`
   - Expiration: 1 year (or your preference)
   - Repository access: **Only select repositories** → `dvh147/sti-summerschool`
   - Permissions → Repository permissions:
     - Contents: **Read and write**
     - Metadata: **Read-only** (auto-selected)
   - Generate, copy the `github_pat_...` token.

2. **Add it as a secret in the private repo**
   - `dvh147/sti26` → Settings → Secrets and variables → Actions → **New repository secret**
   - Name: `PUBLIC_REPO_TOKEN`
   - Value: paste the token.

3. **Trigger the first run**
   - Push any commit to the feature branch (or `main`), or go to Actions →
     "Sync to public site repo" → Run workflow.
   - You should see a commit land in `dvh147/sti-summerschool` attributed
     to `sti26-sync-bot`, followed by a deploy.

After that, every push from me (or you) to the private repo updates the
live site within a couple of minutes — no local terminal work needed.

### Manual sync (fallback)

If the automatic sync isn't set up yet or you want to run it locally, use
`scripts/sync-to-public.ps1` (PowerShell) or `scripts/export-public.sh`
(Bash). See comments in those files.

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
