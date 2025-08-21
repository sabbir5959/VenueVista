-- VenueVista Authentication Table Setup
-- Simple and clean structure for admin, owner, user roles

-- 1) Create user_profiles table (main authentication table)
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone VARCHAR(15),
  role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('admin','owner','user')),
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','suspended')),
  company_name TEXT,              -- For owners only
  avatar_url TEXT,
  city TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2) Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- 3) Create RLS Policies
CREATE POLICY "Users can view own profile" ON public.user_profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
FOR UPDATE USING (auth.uid() = id);

-- 4) Create trigger function for auto profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name, email, role, status)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    'active'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5) Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();







-- Insert Admin Users
UPDATE public.user_profiles SET 
  full_name = 'Diner Ahmed Nissan',
  role = 'admin', 
  phone = '+8801854367299',
  city = 'Dhaka',
  address = 'Shagufta'
WHERE email = 'dinerahmed05@gmail.com';;



-- Then update owner profiles:
UPDATE public.user_profiles SET 
    full_name = 'Tasnuva Islam',
    role = 'owner',
    phone = '+8801700594133',
    company_name = 'Club Volta',
    city = 'Dhaka',
    address = 'Gulshan-2, Dhaka'
WHERE email = 'tasnuvaislam.me@gmail.com';

