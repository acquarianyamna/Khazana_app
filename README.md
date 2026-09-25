# Khazana — Family Expense & Income Ledger

A single-page, installable web app for tracking household income and expenses
across multiple accounts (Easypaisa, JazzCash, bank accounts, wallet). No
backend server — just static files talking directly to Supabase.

## What's in this folder

| File              | Purpose                                              |
|-------------------|-------------------------------------------------------|
| `index.html`      | The entire app — HTML, CSS and JS in one file          |
| `manifest.json`   | Makes it installable on your phone home screen (PWA)   |
| `sw.js`           | Service worker — caches the app shell for offline use  |
| `icon.svg`        | App icon                                                |
| `supabase_setup.sql` | One-time database setup script                       |

## One-time setup (you only do this once)

### 1. Run the database script
In your Supabase project → **SQL Editor** → New query → paste the entire
contents of `supabase_setup.sql` → **Run**.

This creates the tables (`members`, `accounts`, `categories`, `transactions`),
turns on Row Level Security, and seeds your starting categories/accounts.

### 2. Create your shared login
In Supabase → **Authentication → Users → Add user**, create ONE email +
password that you and your wife will both use to sign in. There is no
sign-up screen in the app on purpose — only sign-in.

### 3. Deploy
1. Push this folder to a GitHub repository.
2. Go to [vercel.com](https://vercel.com) → **New Project** → import that repo.
3. Framework preset: **Other** (it's static files, no build step needed).
4. Deploy. You'll get a free `*.vercel.app` URL.

Your Supabase URL and anon key are already wired into `index.html` — nothing
else to configure.

### 4. Install it like an app
Open the deployed link on your phone:
- **Android/Chrome:** you'll get an "Install app" / "Add to Home Screen" prompt.
- **iPhone/Safari:** tap Share → **Add to Home Screen**.

It'll open full-screen with its own icon, like a native app.

## How it's built to scale

- **One `transactions` table** for both income and expense (a `type` column
  tells them apart), so reporting logic stays in one place.
- **Categories, accounts, and members are just database rows** — add, rename,
  or deactivate them anytime from the **Setup** tab. Nothing is hardcoded, so
  new categories show up as tap-able buttons immediately.
- **Soft-deletes only** (an `is_active` flag) — deactivating a category or
  account hides it from the entry screens but keeps historical transactions
  intact and correctly reported.
- **A `meta` JSONB column** on `transactions` is reserved for future features
  (e.g. recurring expenses, budget targets, receipt photos) without ever
  needing a migration that touches existing data.
- Adding a genuinely new feature later (budgets, recurring bills, multi-user
  attribution, reminders) means adding a *new* table that references
  `accounts`/`categories`/`members` by ID — your existing data is never
  restructured.

## Using the app

- **Add Expense / Add Income:** tap denomination buttons to build the amount
  (e.g. tap `1000` then `500` for 1500), pick a category, account, and who's
  logging it, optionally add a note, then save.
- **Dashboard:** pick a date range (or use the quick filters), see account
  balances (always current, all-time), income/expense totals for that period,
  and a breakdown by category. Tap any category to see every transaction in
  a table — with edit and delete right there.
- **Setup:** add new categories, accounts, or members; toggle old ones
  inactive instead of deleting them; export a full JSON backup anytime, or
  import one back in.

## Notes

- The Supabase anon key in `index.html` is meant to be public — real
  protection comes from Row Level Security, which only allows access to
  signed-in users.
- All data lives in Supabase (Postgres), so it syncs instantly between you
  and your wife on any device — nothing is stuck in one phone's browser.
