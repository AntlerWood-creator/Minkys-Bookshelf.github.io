-- Minky's Bookshelf: secure shared data setup for Supabase
-- Run this in Supabase Dashboard > SQL Editor after creating your project.

create table if not exists public.bookshelf_owners (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title text not null default 'Untitled',
  author text not null default 'Unknown author',
  verdict text not null default 'Worth it!' check (verdict in ('Worth it!', 'Don’t read!', 'Depends...')),
  review text not null default '',
  cover text not null default '',
  sort_order bigint not null default 0
);

create table if not exists public.dividers (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  sort_order bigint not null default 0
);

create table if not exists public.drafts (
  id uuid primary key default gen_random_uuid(),
  source_book_id uuid null references public.books(id) on delete set null,
  title text not null default '',
  author text not null default '',
  verdict text not null default 'Worth it!' check (verdict in ('Worth it!', 'Don’t read!', 'Depends...')),
  review text not null default '',
  cover text not null default '',
  sort_order bigint not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.stickers (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) <= 40),
  image text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender text not null default 'A bookish friend' check (char_length(sender) <= 40),
  kind text not null check (kind in ('Book suggestion', 'Author suggestion', 'Reader review', 'Just saying hello', 'Comment')),
  related_book text not null default '' check (char_length(related_book) <= 100),
  body text not null check (char_length(body) between 1 and 1200),
  created_at timestamptz not null default now(),
  is_read boolean not null default false
);

alter table public.bookshelf_owners enable row level security;
alter table public.books enable row level security;
alter table public.dividers enable row level security;
alter table public.drafts enable row level security;
alter table public.stickers enable row level security;
alter table public.messages enable row level security;

-- Anyone may read published books and dividers.
drop policy if exists "Published books are visible" on public.books;
create policy "Published books are visible" on public.books for select to anon, authenticated using (true);
drop policy if exists "Published dividers are visible" on public.dividers;
create policy "Published dividers are visible" on public.dividers for select to anon, authenticated using (true);

-- Owner identity is readable only by the signed-in user whose ID matches.
drop policy if exists "Owner can see own owner record" on public.bookshelf_owners;
create policy "Owner can see own owner record" on public.bookshelf_owners for select to authenticated using (user_id = (select auth.uid()));

-- Only the user manually added to bookshelf_owners can change the shelf.
drop policy if exists "Owner manages books" on public.books;
create policy "Owner manages books" on public.books for all to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())))
with check (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));
drop policy if exists "Owner manages dividers" on public.dividers;
create policy "Owner manages dividers" on public.dividers for all to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())))
with check (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));

drop policy if exists "Owner manages drafts" on public.drafts;
create policy "Owner manages drafts" on public.drafts for all to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())))
with check (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));

drop policy if exists "Owner manages stickers" on public.stickers;
create policy "Owner manages stickers" on public.stickers for all to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())))
with check (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));

-- Readers can send a suggestion/review, but only the owner can read or manage the inbox.
drop policy if exists "Readers can send book mail" on public.messages;
create policy "Readers can send book mail" on public.messages for insert to anon, authenticated with check (true);
drop policy if exists "Owner reads book mail" on public.messages;
create policy "Owner reads book mail" on public.messages for select to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));
drop policy if exists "Owner manages book mail" on public.messages;
create policy "Owner manages book mail" on public.messages for update to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())))
with check (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));
drop policy if exists "Owner deletes book mail" on public.messages;
create policy "Owner deletes book mail" on public.messages for delete to authenticated
using (exists (select 1 from public.bookshelf_owners o where o.user_id = (select auth.uid())));

grant select on public.books, public.dividers to anon, authenticated;
grant insert, update, delete on public.books, public.dividers to authenticated;
grant select, insert, update, delete on public.drafts, public.stickers to authenticated;
grant select on public.bookshelf_owners to authenticated;
grant insert on public.messages to anon, authenticated;
grant select, update, delete on public.messages to authenticated;
