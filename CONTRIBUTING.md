# Contributing

## Local Development

No build tools required. Serve the root directory with any static file server:

```bash
npx serve .
```

Open `http://localhost:3000` in your browser.

## Architecture

The app is three standalone HTML pages with inline JavaScript. There is no framework, bundler, or build step.

| File                  | Role                                      |
|-----------------------|-------------------------------------------|
| `index.html`          | Calculator, auth, save-to-history         |
| `history.html`        | History list, charts, edit/delete entries  |
| `reset-password.html` | Password reset form                       |

Each page creates its own Supabase client and manages auth independently. Shared logic (auth functions, status helpers) is duplicated across pages.

## Supabase Setup

1. Create a free project at [supabase.com](https://supabase.com).
2. Run `supabase-setup.sql` in the SQL Editor.
3. Under **Authentication > URL Configuration**, set:
   - **Site URL:** your local or deployed URL
   - **Redirect URLs:** add your URL + `/reset-password.html`

## Making Changes

- **Styles** are inline `<style>` blocks at the top of each HTML file.
- **JavaScript** is in inline `<script>` blocks at the bottom.
- **Service worker** caches pages listed in `ASSETS_TO_CACHE`. If you add a new page, add it there and bump `CACHE_NAME`.
- **Database schema** changes go in `supabase-setup.sql`. Keep it idempotent (use `IF NOT EXISTS`).

## Deployment

Pushing to `main` triggers automatic deployment via GitHub Actions. The workflow needs two repository secrets:

- `NETLIFY_AUTH_TOKEN`
- `NETLIFY_SITE_ID`
