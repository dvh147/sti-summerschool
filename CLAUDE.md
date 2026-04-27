# CLAUDE.md — project briefing for Claude

> **Maintenance directive (for future Claude sessions).** Keep this file up
> to date. When we agree a new plan, complete a task, add a dependency, or
> change any durable state, edit this file **in the same commit** as the
> change. Short bullets are fine — stale docs are worse than sparse ones.
> The user's expectation is: CLAUDE.md should always reflect current state
> and what's still outstanding.

## Project mission

Build and maintain the website for the **11th STI Summer School on Data and
Algorithms for Science, Technology & Innovation Studies**, 7–9 September
2026, at Valrose Castle, Nice. Static site, hosted on GitHub Pages, zero
budget. Replaces what KU Leuven provided in previous years. Owner: Dennis
Verhoeven (SKEMA).

## Current live state

- Live site: https://stisummerschool.org (custom apex domain on GitHub Pages,
  registered via Cloudflare Registrar). Old preview URL
  https://dvh147.github.io/sti-summerschool/ may still resolve during the
  transition but is no longer canonical.
- 10 pages published: Home, About, Call for Papers, Program, Speakers,
  Registration, Venue, Committee, Contact, Privacy.
- Registration backend: Cloudflare Worker at
  https://sti26-registration.sti2026.workers.dev with D1 storage and a
  token-gated /admin dashboard (delete supported).
- Auto-deploy pipeline working end-to-end (see "How updates flow" below).

## Where everything lives

### Two-repo split

| Repo | Contents | Visibility |
|---|---|---|
| `dvh147/sti26` (this repo) | `/2026/` organizing materials (meeting notes, drafts, Ludo email, keynote priority lists, planning XLSX) **plus** the Astro website source | **private** |
| `dvh147/sti-summerschool` | Mirror of the Astro website source only (no `/2026/`) | **public** |

The site is served from the **public** repo. The user wants the private
organizing materials kept private; that's why we don't just make `sti26`
public. Do not suggest making `sti26` public — it would expose draft emails
and strategic lists.

### How updates flow

1. We commit to `claude/sti-summerschool-website-Kh7q3` (or `main`) in `dvh147/sti26`.
2. `.github/workflows/sync-public.yml` fires, rsyncs the source (excluding
   `/2026/`) into `dvh147/sti-summerschool`, using a fine-grained PAT stored
   in the `PUBLIC_REPO_TOKEN` secret.
3. `.github/workflows/deploy.yml` in the public repo builds the Astro site
   and deploys to GitHub Pages.
4. Total round-trip ~2 minutes.

No local PowerShell work needed for the user in normal operation.

### Key files

- `src/site.ts` — single source of truth for event metadata (dates, fee,
  venue, contact, partners, deadlines). Edit here, reflected everywhere.
- `src/pages/*.astro` — page content.
- `src/components/*.astro` — shared UI (Header, Footer, Hero, KeyDates, Partners).
- `src/styles/global.css` — design tokens (Mediterranean palette, Fraunces+Inter).
- `public/images/valrose.jpg` — hero/venue photo.
- `public/docs/STI-2026-Call-for-Papers.pdf` — CfP PDF (user-supplied).
- `2026/` — source materials; **never publish, never delete without asking**.
- `.github/workflows/sync-public.yml` — auto-sync workflow (private repo only).
- `.github/workflows/deploy.yml` — build+deploy (guarded so it runs only in the public repo).
- `scripts/sync-to-public.ps1` — PowerShell fallback for manual sync.
- `scripts/export-public.sh` — Bash fallback (used for the initial bootstrap).

## Decisions already made (don't re-litigate without cause)

- **Stack:** Astro + Markdown/MDX, plain CSS with design tokens. No Tailwind.
- **Hosting:** GitHub Pages on the public repo.
- **Form backend:** self-hosted Cloudflare Worker (`worker/`) with D1
  storage, server-side Turnstile captcha, optional Resend email, and a
  token-gated `/admin` dashboard. Replaced the original Formspree wiring.
  Public site reads `PUBLIC_REGISTRATION_API` and `PUBLIC_TURNSTILE_SITE_KEY`
  as repo variables on `dvh147/sti-summerschool`.
- **Language:** English only.
- **Visual:** clean academic with Mediterranean/Côte d'Azur palette (primary
  `#0a4a7a`, accent `#2fa4c4`, sand bg `#f6f1e7`). Serif = Fraunces,
  sans = Inter.
- **Payment:** no online payment for v1. Placeholder block on the Registration
  page points to SEPA bank transfer to SKEMA (IBAN TBD) with reference
  `STI2026-<lastname>`, plus a "optional payment link to be confirmed" line.
- **Program page:** shows high-level 3-day shape only. Full schedule posts
  after 22 May 2026 (paper acceptance notifications).
- **Scope v1:** 10 pages including stubs (we built more than the MVP because
  the CfP gave us real content for Speakers, Committee, etc.).

## Outstanding items (update as they land)

- [ ] **SKEMA bank details** — IBAN, BIC, account holder name, any payment-link URL.
      Location to update: `src/pages/registration.astro` (payment callout block).
- [ ] **Resend email** (optional). Worker is wired but skips silently
      without `RESEND_API_KEY` + `FROM_EMAIL` secrets. Easiest after the
      domain DNS propagates and we can verify `noreply@stisummerschool.org`
      in Resend.
- [ ] **Partner logos** — currently text chips. User can drop PNG/SVG into
      `public/images/logos/` and I'd wire them into `src/components/Partners.astro`.
- [ ] **Program page real schedule** — after 22 May 2026 acceptances. The
      previous detailed schedule is in git history (commit `1e27f0a^`) if
      we want to restore the layout and fill in real sessions.
- [ ] **CfP PDF typo** — PDF lists Dieter Kogler as "UCB"; site says "UCD Dublin".
      User should regenerate the PDF with the corrected "UCD". (Site-side
      is already correct in `src/pages/call-for-papers.astro` and
      `src/pages/committee.astro`.)

## Constraints and gotchas

- **Do not push to `dvh147/sti-summerschool` directly.** The sync workflow owns it.
  Any manual commit there will be overwritten on the next sync
  (`rsync --delete` mirrors the source of truth).
- **Do not add `.github/workflows/sync-public.yml` to the public repo.** The
  `if: github.repository == 'dvh147/sti26'` guard prevents it from running
  if it ever ends up there, but it shouldn't be there in the first place.
- **Worker CORS allowlist.** `worker/wrangler.toml` `ALLOWED_ORIGINS` must
  list every origin that can POST the form (apex `stisummerschool.org`,
  `www`, `dvh147.github.io` during transition, `localhost:4321` for dev).
  After editing, redeploy the worker with `cd worker && npm run deploy`.
- **Repo variables on the public repo.** Build needs `SITE_URL`,
  `PUBLIC_REGISTRATION_API`, `PUBLIC_TURNSTILE_SITE_KEY` set on
  `dvh147/sti-summerschool` Variables tab (not Secrets). `BASE_PATH` should
  be unset for the apex domain; only set it if a future deploy serves
  from a subpath.
- **GDPR.** Registration collects personal data in the EU. The `/privacy`
  page exists; keep it truthful if the form's backend or processors change.
- **Dropbox pathing.** User's local clone is under `C:\Users\dennis.verhoeven\Dropbox (Personal)\...`.
  Dropbox-syncing `.git` can corrupt git state; we've warned them once. If
  they report weird git errors, remind them to move the working folder
  out of Dropbox.

## User preferences / style

- Frugal with GitHub comments and PRs. Don't open PRs or post review
  comments unless explicitly asked.
- The user is not a developer but is comfortable copy-pasting commands.
- Prefer one concrete next action over option buffets.
- For UI changes, push and tell them the preview URL to check; they'll
  eyeball it and flag issues.

## Recent history (short)

- **2026-04-22** — Initial scaffold, 10 pages, sync pipeline, CLAUDE.md added.
  Program page moved to TBA state per user request.
- **2026-04-27** — Replaced Formspree with self-hosted Cloudflare Worker
  + D1 + Turnstile. Admin dashboard with status updates, CSV export, and
  per-row delete. Domain `stisummerschool.org` purchased (Cloudflare
  Registrar) and wired up: CNAME committed, default `SITE_URL` switched
  to apex, `BASE_PATH` cleared, worker `ALLOWED_ORIGINS` updated.

## Pointers for future sessions

- `README.md` explains deploy / manual-sync details for humans.
- Commits are conventional-ish: present tense, short subject, paragraph body.
- Stick with Astro. If tempted to switch to Next.js or add Tailwind, don't —
  ask the user first.
