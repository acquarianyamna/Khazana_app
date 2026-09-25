-- ============================================================
-- Khizar Family Expense Tracker — Database Setup
-- Run this ONCE in Supabase: Project → SQL Editor → New query → Run
-- Safe to re-run: uses "if not exists" / "on conflict do nothing"
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- MEMBERS (who is logging the entry) ----------
create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- ACCOUNTS (wallets / bank / mobile money) ----------
create table if not exists accounts (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- CATEGORIES (both income & expense, one scalable table) ----------
create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('income','expense')),
  name text not null,
  icon text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  unique(kind, name)
);

-- ---------- TRANSACTIONS (single table for income + expense) ----------
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('income','expense')),
  amount numeric(12,2) not null check (amount > 0),
  account_id uuid not null references accounts(id),
  category_id uuid not null references categories(id),
  member_id uuid references members(id),
  note text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  meta jsonb not null default '{}'::jsonb  -- reserved for future features, no migration needed
);

create index if not exists idx_tx_occurred_at on transactions(occurred_at desc);
create index if not exists idx_tx_type on transactions(type);
create index if not exists idx_tx_account on transactions(account_id);
create index if not exists idx_tx_category on transactions(category_id);
create index if not exists idx_tx_member on transactions(member_id);

-- ---------- ROW LEVEL SECURITY ----------
-- Shared login: any authenticated user (you two) has full access.
alter table members enable row level security;
alter table accounts enable row level security;
alter table categories enable row level security;
alter table transactions enable row level security;

drop policy if exists "auth full access members" on members;
create policy "auth full access members" on members
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "auth full access accounts" on accounts;
create policy "auth full access accounts" on accounts
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "auth full access categories" on categories;
create policy "auth full access categories" on categories
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "auth full access transactions" on transactions;
create policy "auth full access transactions" on transactions
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ---------- SEED DATA ----------
insert into members (name, sort_order) values
  ('Me', 1), ('Wife', 2)
on conflict (name) do nothing;

insert into accounts (name, sort_order) values
  ('Easypaisa', 1),
  ('Jazz Cash', 2),
  ('Askari Salary Account', 3),
  ('Askari Other Account', 4),
  ('Wallet', 5)
on conflict (name) do nothing;

insert into categories (kind, name, sort_order) values
  ('expense', 'Vegetable', 1),
  ('expense', 'Soft Drink', 2),
  ('expense', 'Bike Fuel', 3),
  ('expense', 'Car Fuel', 4),
  ('expense', 'Grocery Item', 5),
  ('expense', 'Processed Food', 6),
  ('expense', 'Khizar Items', 7),
  ('expense', 'Shopping', 8),
  ('expense', 'Home Decor & Maintenance', 9),
  ('expense', 'Bike/Car Maintenance', 10),
  ('income', 'Salary', 1),
  ('income', 'Tuition Fees', 2),
  ('income', 'BC Amount', 3)
on conflict (kind, name) do nothing;

-- ---------- CREATE YOUR SHARED LOGIN ----------
-- Go to: Authentication → Users → Add user (in the Supabase dashboard)
-- Create ONE email + password you and your wife will both use to sign in.
-- Do not use "Sign up" from the app itself — this app has no signup screen on purpose.
