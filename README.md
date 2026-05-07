# Wolt Income Splitter

A Progressive Web App for splitting delivery income across multiple workers. Built for Wolt couriers, fleet owners, and small teams who share vehicles or accounts.

**Live:** [wolt-income-spliter.netlify.app](https://wolt-income-spliter.netlify.app/)

---

## What It Does

A fleet owner runs a Wolt delivery account with multiple drivers. At the end of each work period, the gross income needs to be divided: the owner takes a commission, shared expenses are deducted, and the remaining pool is split proportionally among workers based on what each person earned.

This app automates that calculation, saves every split to a personal history, and shows earnings analytics over time.

## Features

- **Income Splitting** -- Enter each worker's gross earnings, set the owner's commission percentage and shared expenses, and get an instant breakdown of everyone's take-home pay.
- **Work Period Tracking** -- Pick custom date ranges for each pay period.
- **History & Analytics** -- Every calculation is saved. View past splits, see total earnings over time via line charts, and edit or delete old entries.
- **Per-User Data Isolation** -- Each account only sees its own data. Row-level security enforced at the database level.
- **Forgot Password** -- Email-based password reset flow with a dedicated reset page.
- **Installable PWA** -- Add to your phone's home screen. Works offline for cached pages.
- **Mobile-First Design** -- Responsive layout optimized for phones, works on all screen sizes.

## How the Split Works

```
Inputs:
  Total Gross     = sum of all workers' gross earnings
  Expenses        = shared costs (fuel, phone, etc.)
  Commission %    = owner's cut percentage

Calculation:
  Net Income      = Total Gross - Expenses
  Owner Cut       = Net Income x (Commission% / 100)
  Workers Pool    = Net Income - Owner Cut

Per worker:
  Proportion      = Worker Gross / Total Gross
  Take-Home       = Workers Pool x Proportion
```

Workers who earned more gross get a proportionally larger share of the pool.

## Tech Stack

| Layer          | Technology                              |
|----------------|-----------------------------------------|
| Frontend       | Vanilla HTML/CSS/JS (no build step)     |
| Auth & DB      | [Supabase](https://supabase.com) (PostgreSQL + Auth) |
| Charts         | [Chart.js](https://www.chartjs.org/) via CDN |
| Hosting        | [Netlify](https://www.netlify.com/)     |
| CI/CD          | GitHub Actions                          |
| PWA            | Service Worker + Web App Manifest       |

No frameworks, no bundler, no `node_modules`. The entire app is three HTML files with inline `<script>` tags, served as a static site.

## Project Structure

```
.
├── index.html              # Main calculator page + auth
├── history.html            # History list, analytics, edit/delete
├── reset-password.html     # Password reset form
├── service-worker.js       # Offline caching
├── manifest.json           # PWA metadata
├── app-icon.svg            # App icon
├── supabase-setup.sql      # Database schema + RLS policies
├── netlify.toml            # Netlify config
└── .github/
    └── workflows/
        └── deploy.yaml     # Auto-deploy on push to main
```

## Getting Started

### Prerequisites

- A [Supabase](https://supabase.com) project (free tier works)
- A [Netlify](https://www.netlify.com) account (or any static host)

### 1. Set Up the Database

Run [`supabase-setup.sql`](supabase-setup.sql) in your Supabase SQL Editor. This creates the `wolt_splits` table with row-level security policies so each user can only access their own data.

### 2. Configure Supabase Credentials

In `index.html`, `history.html`, and `reset-password.html`, update these constants with your own Supabase project values:

```js
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

You'll find both in the Supabase dashboard under **Settings > API**.

### 3. Configure Redirect URLs

In the Supabase dashboard under **Authentication > URL Configuration**:

- **Site URL:** `https://your-domain.netlify.app/`
- **Redirect URLs:** Add `https://your-domain.netlify.app/reset-password.html`

Update `APP_URL` in `index.html` and `history.html` to match your deployed domain.

### 4. Deploy

**Option A -- Netlify CLI:**
```bash
npx netlify deploy --prod --dir .
```

**Option B -- GitHub Actions (automated):**
1. Push to a GitHub repo.
2. Add repository secrets: `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID`.
3. Every push to `main` triggers automatic deployment.

**Option C -- Local development:**
```bash
# Any static file server works
npx serve .
# or
python -m http.server 8000
```

## Database Schema

### `public.wolt_splits`

| Column         | Type          | Description                                    |
|----------------|---------------|------------------------------------------------|
| `id`           | `uuid`        | Primary key (auto-generated)                   |
| `user_id`      | `uuid`        | References `auth.users(id)`, cascade on delete |
| `user_email`   | `text`        | Email of the user who saved the entry          |
| `owner_name`   | `text`        | Name of the fleet owner                        |
| `work_period`  | `text`        | Date range label (e.g. "Apr 1 to Apr 15")      |
| `total_gross`  | `numeric`     | Sum of all workers' gross earnings             |
| `owner_cut`    | `numeric`     | Commission amount                              |
| `expenses`     | `numeric`     | Shared expenses deducted                       |
| `workers_data` | `jsonb`       | Array of `{name, gross, final_share}` objects  |
| `created_at`   | `timestamptz` | When the entry was saved                       |

### Row-Level Security

All operations (SELECT, INSERT, UPDATE, DELETE) are restricted to `auth.uid() = user_id`. Users cannot read, modify, or delete other users' data.

### Indexes

- **`wolt_splits_id_idx`** -- Unique index on `id`
- **`wolt_splits_user_created_idx`** -- Composite index on `(user_id, created_at DESC)` for efficient per-user queries

## Authentication

The app uses Supabase Auth with email/password:

| Flow             | Description                                                    |
|------------------|----------------------------------------------------------------|
| **Sign Up**      | Creates account, sends verification email, redirects to app    |
| **Log In**       | Email + password authentication                                |
| **Forgot Password** | Sends reset email, user lands on `reset-password.html`     |
| **Password Reset** | User sets new password, then redirected to login             |
| **Log Out**      | Clears session, returns to login form                          |

Sessions persist across page reloads via Supabase's built-in token management in `localStorage`.

## Deployment

### Netlify

The site is configured as a static deployment with no build step. `netlify.toml` sets the publish directory to root (`.`).

### GitHub Actions

The workflow at [`.github/workflows/deploy.yaml`](.github/workflows/deploy.yaml) deploys on every push to `main` or `master`:

1. Checks out the code
2. Deploys to Netlify via `nwtgck/actions-netlify@v3.0`

**Required secrets:**

| Secret               | Where to find it                              |
|----------------------|-----------------------------------------------|
| `NETLIFY_AUTH_TOKEN`  | Netlify > User Settings > Applications > Personal access tokens |
| `NETLIFY_SITE_ID`    | Netlify > Site Settings > General > Site ID   |

### Service Worker & Caching

The service worker (`service-worker.js`) caches all app assets on install and serves them cache-first. When you update files, bump `CACHE_NAME` (currently `wolt-income-splitter-v2`) so returning users get fresh assets.

## License

This project is unlicensed. All rights reserved.
