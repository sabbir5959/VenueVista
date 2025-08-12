-- Enable needed extension (usually pre-enabled in Supabase)


create extension if not exists pgcrypto;



-- 1) user_profiles (extends auth.users)
create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone varchar(15) unique,
  role varchar(20) not null default 'user' check (role in ('admin','owner','user')),
  status varchar(20) not null default 'active' check (status in ('active','inactive','suspended')),
  company_name text,             -- for owners (optional)
  avatar_url text,
  city text,
  address text,
  joined_at timestamptz default now(),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);



-- 2) venues
create table if not exists public.venues (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.user_profiles(id) on delete cascade,
  name text not null,
  description text,
  venue_type text not null,        -- e.g. football, futsal, cricket
  price_per_hour numeric(10,2) not null,
  capacity int,
  size text,                       -- e.g. "105x68 m"
  phone text,
  email text,
  address text not null,
  city text not null,
  latitude numeric(10,6),
  longitude numeric(10,6),
  opening_time time default '06:00',
  closing_time time default '23:00',
  commission_rate numeric(5,2) default 10.00,
  status text not null default 'active' check (status in ('active','inactive','maintenance','pending')),
  is_approved boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);



-- 3) venue_images
create table if not exists public.venue_images (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  url text not null,
  is_cover boolean default false,
  sort_order int default 0,
  created_at timestamptz default now()
);



-- 4) venue_facilities
create table if not exists public.venue_facilities (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  name text not null,              -- e.g. Parking, Lights, Washroom
  icon text,
  is_available boolean default true,
  created_at timestamptz default now()
);



-- 5) venue_maintenance_logs
create table if not exists public.venue_maintenance_logs (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  title text not null,
  notes text,
  start_date date not null,
  end_date date,
  status text default 'scheduled' check (status in ('scheduled','in_progress','done','cancelled')),
  created_at timestamptz default now()
);



-- 6) venue_pricing_rules (dynamic pricing by slot/day)
create table if not exists public.venue_pricing_rules (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  day_of_week int check (day_of_week between 0 and 6), -- 0=Sun
  start_time time not null,
  end_time time not null,
  price_per_hour numeric(10,2) not null,
  is_active boolean default true,
  created_at timestamptz default now()
);



-- 7) bookings
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_code text unique not null,      -- e.g. BK20250809-0012
  user_id uuid not null references public.user_profiles(id) on delete restrict,
  venue_id uuid not null references public.venues(id) on delete restrict,
  booking_date date not null,
  start_time time not null,
  end_time time not null,
  duration_hours numeric(4,2) not null,
  base_price numeric(10,2) not null,
  additional_fees numeric(10,2) default 0.00,
  total_amount numeric(10,2) not null,
  status text default 'pending' check (status in ('pending','confirmed','completed','cancelled')),
  payment_status text default 'pending' check (payment_status in ('pending','paid','refunded','partial')),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);



-- 8) payments (includes admin-to-owner cash)
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  payment_code text unique not null,      -- e.g. PAY-2025-0001
  transaction_id text,                    -- gateway/ref id
  amount numeric(12,2) not null,
  payment_method text not null,           -- bkash,nagad,bank,cash,card
  direction text not null check (direction in ('from_user','to_owner','refund')),
  status text default 'pending' check (status in ('pending','processing','completed','failed','cancelled')),
  description text not null,

  payer_id uuid references public.user_profiles(id),
  receiver_id uuid references public.user_profiles(id),
  venue_id uuid references public.venues(id),
  booking_id uuid references public.bookings(id),

  contact_person text,                    -- for cash
  contact_phone text,
  metadata jsonb default '{}'::jsonb,

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);



-- 9) venue_reviews
create table if not exists public.venue_reviews (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  user_id uuid not null references public.user_profiles(id) on delete cascade,
  booking_id uuid references public.bookings(id),
  rating int not null check (rating between 1 and 5),
  review_text text,
  images text[],
  is_verified boolean default false,
  created_at timestamptz default now(),
  unique (venue_id, user_id, booking_id)
);



-- 10) notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_profiles(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null,                      -- booking,payment,tournament,system
  related_id uuid,
  action_url text,
  is_read boolean default false,
  created_at timestamptz default now()
);



-- 11) tournaments
create table if not exists public.tournaments (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete restrict,
  organizer_id uuid references public.user_profiles(id),
  tournament_code text unique not null,
  name text not null,
  description text,
  tournament_date date not null,
  start_time time not null,
  duration_hours int,
  max_teams int not null,
  players_per_team int not null,
  entry_fee numeric(10,2) not null,
  prize_money jsonb,                       -- {"first":50000,"second":30000}
  sport_type text not null,
  status text default 'registration_open' check (status in ('registration_open','registration_closed','active','completed','cancelled')),
  image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);



-- 12) tournament_registrations
create table if not exists public.tournament_registrations (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  team_captain_id uuid not null references public.user_profiles(id) on delete restrict,
  team_name text not null,
  team_members jsonb,                      -- array of players
  registration_fee numeric(10,2) not null,
  payment_status text default 'pending' check (payment_status in ('pending','paid','refunded')),
  status text default 'registered' check (status in ('registered','confirmed','disqualified')),
  created_at timestamptz default now()
);



-- 13) tournament_matches
create table if not exists public.tournament_matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  round text,                              -- group, quarter, semi, final
  team_a jsonb not null,                   -- {"name":"A FC","id": "..."}
  team_b jsonb not null,
  scheduled_at timestamptz,
  score_a int,
  score_b int,
  status text default 'scheduled' check (status in ('scheduled','live','finished','walkover','cancelled')),
  created_at timestamptz default now()
);



-- 14) app_settings
create table if not exists public.app_settings (
  id uuid primary key default gen_random_uuid(),
  setting_key text unique not null,
  setting_value jsonb not null,
  description text,
  updated_by uuid references public.user_profiles(id),
  updated_at timestamptz default now()
);



-- 15) activity_logs (auditing)
create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.user_profiles(id),
  action text not null,                    -- e.g. "owner.update"
  entity text not null,                    -- e.g. "venue","booking"
  entity_id uuid,
  details jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);