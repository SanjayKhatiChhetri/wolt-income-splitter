create extension if not exists pgcrypto;

create table if not exists public.wolt_splits (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    user_email text,
    work_period text not null,
    total_gross numeric not null default 0,
    owner_cut numeric not null default 0,
    expenses numeric not null default 0,
    workers_data jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now()
);

alter table public.wolt_splits add column if not exists id uuid default gen_random_uuid();
alter table public.wolt_splits add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.wolt_splits add column if not exists user_email text;
alter table public.wolt_splits add column if not exists work_period text;
alter table public.wolt_splits add column if not exists total_gross numeric default 0;
alter table public.wolt_splits add column if not exists owner_cut numeric default 0;
alter table public.wolt_splits add column if not exists expenses numeric default 0;
alter table public.wolt_splits add column if not exists workers_data jsonb default '[]'::jsonb;
alter table public.wolt_splits add column if not exists created_at timestamptz default now();

update public.wolt_splits
set id = gen_random_uuid()
where id is null;

create unique index if not exists wolt_splits_id_idx on public.wolt_splits (id);
create index if not exists wolt_splits_user_created_idx on public.wolt_splits (user_id, created_at desc);

alter table public.wolt_splits enable row level security;

do $$
begin
    if not exists (
        select 1
        from pg_constraint
        where conname = 'wolt_splits_pkey'
    ) then
        alter table public.wolt_splits add constraint wolt_splits_pkey primary key (id);
    end if;
end $$;

do $$
begin
    if not exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'wolt_splits'
          and policyname = 'Users can view their own splits'
    ) then
        create policy "Users can view their own splits"
        on public.wolt_splits
        for select
        using (auth.uid() = user_id);
    end if;
end $$;

do $$
begin
    if not exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'wolt_splits'
          and policyname = 'Users can insert their own splits'
    ) then
        create policy "Users can insert their own splits"
        on public.wolt_splits
        for insert
        with check (auth.uid() = user_id);
    end if;
end $$;

do $$
begin
    if not exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'wolt_splits'
          and policyname = 'Users can update their own splits'
    ) then
        create policy "Users can update their own splits"
        on public.wolt_splits
        for update
        using (auth.uid() = user_id)
        with check (auth.uid() = user_id);
    end if;
end $$;

do $$
begin
    if not exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'wolt_splits'
          and policyname = 'Users can delete their own splits'
    ) then
        create policy "Users can delete their own splits"
        on public.wolt_splits
        for delete
        using (auth.uid() = user_id);
    end if;
end $$;
