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
  registered via Cloudflare Registrar).
- 10 pages published: Home, About, Call for Papers, Program, Speakers,
  Registration, Venue, Committee, Contact, Privacy.
- Registration backend: Cloudflare Worker at
  https://sti26-registration.sti2026.workers.dev with D1 storage.
  - **Public form** posts to `/api/register` with Turnstile captcha.
  - **Admin dashboard** at `/admin` (token-gated client-side via Bearer header).
    Features: stats tiles (total / confirmed / paid / unpaid / presenting /
    cancelled), CSV export, status + payment-status edits, per-row delete,
    per-row "Send payment reminder" button (tracks count + last-sent
    timestamp), and a "Compose message to participants" panel for bulk
    sends with filters (all / unpaid / paid / confirmed / presenting).
- Email pipeline live via Resend.
  - Sender: `STI Summer School 2026 <summerschool@stisummerschool.org>`.
  - Reply-to: `sti@kuleuven.be` on every outbound message.
  - Confirmation email auto-sends on registration with payment block
    (placeholder IBAN until SKEMA confirms) and a yellow "please add us
    to your contacts" callout for deliverability.
  - Domain `stisummerschool.org` is fully verified in Resend (DKIM/SPF/DMARC),
    sending from the EU/Dublin region.
- All work consolidated to `main`. Auto-deploy pipeline runs on push to
  main only (see "How updates flow" below).

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

**Website** (commits land on `main`):
1. Push to `main` in `dvh147/sti26`.
2. `.github/workflows/sync-public.yml` fires, rsyncs the source (excluding
   `/2026/` and `worker/`) into `dvh147/sti-summerschool`, using a
   fine-grained PAT stored in the `PUBLIC_REPO_TOKEN` secret.
3. `.github/workflows/deploy.yml` in the public repo builds the Astro site
   and deploys to GitHub Pages.
4. Total round-trip ~2 minutes.

**Worker** (Cloudflare backend, lives in `worker/` — NOT synced to public repo):
- Deploys are manual. From the user's PowerShell:
  ```
  cd worker
  npm run deploy
  ```
- Wrangler reads `worker/wrangler.toml` for config and uses the user's
  Cloudflare OAuth token (set via `npx wrangler login`).
- Secrets are not in the repo. They live on the worker:
  `TURNSTILE_SECRET_KEY`, `ADMIN_TOKEN`, `RESEND_API_KEY`, `FROM_EMAIL`,
  optional `NOTIFY_EMAIL`. Set with `npx wrangler secret put <NAME>`.
- D1 schema migrations live in `worker/migrations/`. Run with
  `npm run db:migrate:reminders` (or any script added to `package.json`).

No local PowerShell work needed for the user in normal website operation.
Worker changes do require the user to run `npm run deploy`.

### Key files

Website:
- `src/site.ts` — single source of truth for event metadata (dates, fee,
  venue, contact, partners, deadlines). Edit here, reflected everywhere.
- `src/pages/*.astro` — page content.
- `src/pages/registration.astro` — registration form. Posts to the worker.
  Renders Turnstile widget. Has the success callout with whitelist guidance.
- `src/components/*.astro` — shared UI (Header, Footer, Hero, KeyDates, Partners).
- `src/styles/global.css` — design tokens (Mediterranean palette, Fraunces+Inter).
- `public/images/valrose.jpg` — hero/venue photo.
- `public/docs/STI-2026-Call-for-Papers.pdf` — CfP PDF (user-supplied).
- `public/CNAME` — `stisummerschool.org`. Required for GitHub Pages apex.
- `2026/` — source materials; **never publish, never delete without asking**.

Worker:
- `worker/src/index.js` — single-file Worker. Routes: `/api/register`,
  `/api/registrations` (GET/PATCH/DELETE), `/api/registrations/:id/send-reminder`,
  `/api/announce`, `/admin`. Email helpers (`sendEmail`, `sendBatchEmails`),
  payment-instructions block (`paymentInstructionsHtml` — update IBAN/BIC
  here when SKEMA confirms), and the inline admin HTML.
- `worker/schema.sql` — initial D1 schema (CREATE TABLE IF NOT EXISTS).
- `worker/migrations/*.sql` — incremental migrations. Run via npm scripts.
- `worker/wrangler.toml` — D1 binding (real DB id pinned), `ALLOWED_ORIGINS`
  CORS allowlist (apex + www + dvh147.github.io + localhost:4321).
- `worker/package.json` — `deploy`, `db:init`, `db:migrate:reminders`, `tail`.

CI:
- `.github/workflows/sync-public.yml` — runs on push to `main` only.
  Excludes `worker/`, `2026/`, build artifacts.
- `.github/workflows/deploy.yml` — guarded so only the public repo runs it.
- `scripts/sync-to-public.ps1` / `scripts/export-public.sh` — manual fallbacks.

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

- [ ] **User's in-depth review** — at end of session 2026-04-28, user said
      they will go through the live site and admin in detail and bring back
      a list of comments/changes for the next session. Expect a punch list.
- [ ] **SKEMA bank details** — IBAN, BIC, account holder name, any
      payment-link URL. Locations to update:
      - `src/pages/registration.astro` (payment callout block on the site).
      - `worker/src/index.js` → `paymentInstructionsHtml()` (used in both
        confirmation and reminder emails). Currently `to be communicated`.
      Worker change requires `npm run deploy`.
- [ ] **Email deliverability watch** — fresh sending domain. First test
      emails landed in spam; we mitigated with: (a) switched FROM from
      `noreply@` to `summerschool@stisummerschool.org`, (b) added a yellow
      "add us to contacts" callout to the confirmation email, (c) added an
      explicit spam-check + whitelist note to the registration success
      page. Reputation will improve as recipients interact. If deliverability
      is still poor after a dozen real registrations, consider asking the
      user to send a one-line "expect mail from us" announcement from
      `sti@kuleuven.be` to their list.
- [ ] **Partner logos** — currently text chips. User can drop PNG/SVG into
      `public/images/logos/` and we'd wire them into `src/components/Partners.astro`.
- [ ] **Program page real schedule** — after 22 May 2026 acceptances. The
      previous detailed schedule is in git history (commit `1e27f0a^`) if
      we want to restore the layout and fill in real sessions.
- [ ] **CfP PDF typo** — PDF lists Dieter Kogler as "UCB"; site says "UCD Dublin".
      User should regenerate the PDF with the corrected "UCD". (Site-side
      is already correct in `src/pages/call-for-papers.astro` and
      `src/pages/committee.astro`.)

## Things already done (do not redo)

- [x] **Site live on apex** `stisummerschool.org` (Cloudflare Registrar).
      `BASE_PATH` is intentionally empty; only set if a future deploy
      moves to a subpath.
- [x] **Registration backend** (Worker + D1 + Turnstile + admin dashboard).
- [x] **Resend email** — verified domain, all three features (confirmation,
      per-row reminder, bulk announce). FROM = `summerschool@stisummerschool.org`,
      reply-to = `sti@kuleuven.be`.
- [x] **Branch consolidation 2026-04-28** — all work on `main`. Old
      `claude/*` branches deleted from origin.

## Constraints and gotchas

- **Do not push to `dvh147/sti-summerschool` directly.** The sync workflow owns it.
  Any manual commit there will be overwritten on the next sync
  (`rsync --delete` mirrors the source of truth).
- **Do not add `.github/workflows/sync-public.yml` to the public repo.** The
  `if: github.repository == 'dvh147/sti26'` guard prevents it from running
  if it ever ends up there, but it shouldn't be there in the first place.
- **Worker CORS allowlist.** `worker/wrangler.toml` `ALLOWED_ORIGINS` must
  list every origin that can POST the form (apex, `www`, `dvh147.github.io`
  during transition, `localhost:4321` for dev). After editing, redeploy
  the worker with `cd worker && npm run deploy`.
- **Repo variables on the public repo.** Build needs `SITE_URL`,
  `PUBLIC_REGISTRATION_API`, `PUBLIC_TURNSTILE_SITE_KEY` set on
  `dvh147/sti-summerschool` → Settings → Secrets and variables → Actions
  → **Variables** tab (not Secrets — they need to be readable by the build).
  `BASE_PATH` should be unset for the apex domain.
- **D1 has only one DB.** ID `539039ee-a948-4c70-a579-8426241a4885` is
  pinned in `worker/wrangler.toml`. Don't run `wrangler d1 create` again
  unless we're starting fresh.
- **Resend domain region.** Verified in Dublin (EU) — keep it. Switching
  region invalidates verification.
- **Worker code is NOT synced to the public repo** (sync excludes `worker/`).
  This is deliberate — the public repo is just the website. Worker
  source stays only in the private repo.
- **GDPR.** Registration collects personal data in the EU. The `/privacy`
  page exists; keep it truthful if the form's backend or processors change.
- **Dropbox pathing.** User's local clone is under `C:\Users\dennis.verhoeven\Dropbox (Personal)\...`.
  Dropbox-syncing `.git` can corrupt git state. If the user reports weird
  git errors, remind them to move the working folder out of Dropbox.

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
- **2026-04-28** — Email functionality. Resend verified for the domain;
  three flows live: confirmation on registration (with payment block +
  whitelist callout), per-row "Send payment reminder" button, and bulk
  "Compose message to participants" panel. Schema gained
  `payment_reminder_sent_at` + `payment_reminder_count`. Admin dashboard
  gained stats tiles at the top (total / confirmed / paid / unpaid /
  presenting / cancelled). FROM switched from `noreply@` to
  `summerschool@stisummerschool.org` for deliverability. All branches
  consolidated to `main`; legacy feature branches deleted from origin.
  User has the live system working end to end and will return next
  session with a punch list of changes after their own deep review.

## Pointers for future sessions

- `README.md` explains deploy / manual-sync details for humans.
- Commits are conventional-ish: present tense, short subject, paragraph body.
- Stick with Astro. If tempted to switch to Next.js or add Tailwind, don't —
  ask the user first.
- The user does not normally run a local dev server. For UI changes,
  push to `main`, wait ~2 min, and tell them to refresh the live site.
- Worker logs: `cd worker && npm run tail` streams realtime logs from
  Cloudflare (useful for debugging email sends or CORS rejections).
- Admin token is stored client-side in localStorage on `/admin` once
  pasted. The user's token lives in the worker as the `ADMIN_TOKEN` secret.
