# CLAUDE.md

## Project Overview

Wolt Income Splitter -- a PWA for splitting delivery income among fleet workers. Static site (no build step), Supabase backend, deployed to Netlify.

## Key Constraints

- No frameworks. Vanilla HTML/CSS/JS with CDN libraries (Supabase JS, Chart.js).
- Each HTML page is self-contained: own `<style>`, own `<script>`, own Supabase client instance.
- Auth logic is duplicated across `index.html`, `history.html`, and `reset-password.html`.
- All data access goes through Supabase with row-level security. Users can only see their own rows.
- `localStorage` is used as a fallback data source when Supabase is unreachable.

## Common Tasks

**Add a new page:**
1. Create the HTML file with its own Supabase client init, auth functions, and styles.
2. Add the path to `ASSETS_TO_CACHE` in `service-worker.js`.
3. Bump `CACHE_NAME` in `service-worker.js`.

**Change the database schema:**
1. Edit `supabase-setup.sql` (keep it idempotent with `IF NOT EXISTS`).
2. Run the updated SQL in the Supabase dashboard.

**Update Supabase credentials:**
Update `SUPABASE_URL` and `SUPABASE_ANON_KEY` in all three HTML files.

## Testing

No test suite. Verify changes by serving locally (`npx serve .`) and testing in the browser.

## Deployment

Push to `main` -- GitHub Actions deploys to Netlify automatically. Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as repository secrets.
