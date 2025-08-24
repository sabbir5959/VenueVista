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




-- Insert Venue 
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status
) 
SELECT 
    up.id, 'Dhanmondi Football Arena', 
    'Professional standard football ground with FIFA approved grass. Perfect for tournaments and league matches. Modern facilities with excellent drainage system.',
    'House 32, Road 7, Dhanmondi, Dhaka-1205', 'Dhaka', 2500.00, 500.00, 22, '100m x 60m',
    ARRAY['Floodlights', 'Changing Rooms', 'Parking', 'Security', 'Washrooms', 'Water Supply', 'First Aid', 'Canteen', 'WiFi'],
    4.7, 'active'
FROM public.user_profiles up
WHERE up.email = 'karim.ahmed@example.com' AND up.role = 'owner';





















-- Update owner profiles for dummy emails
UPDATE public.user_profiles SET 
    full_name = 'Karim Ahmed',
    role = 'owner',
    phone = '+8801712345678',
    company_name = 'Dhaka Sports Complex',
    city = 'Dhaka',
    address = 'Dhanmondi, Dhaka'
WHERE email = 'karim.ahmed@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Rahim Khan',
    role = 'owner',
    phone = '+8801812345679',
    company_name = 'Dhaka Football Academy',
    city = 'Dhaka',
    address = 'Agrabad, Dhaka'
WHERE email = 'rahim.khan@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Salim Uddin',
    role = 'owner',
    phone = '+8801912345680',
    company_name = 'Dhaka Sports Ground',
    city = 'Dhaka',
    address = 'Zindabazar, Dhaka'
WHERE email = 'salim.uddin@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Nasir Hossain',
    role = 'owner',
    phone = '+8801612345681',
    company_name = 'Dhaka Sports Club',
    city = 'Dhaka',
    address = 'Kandirpar, Dhaka'
WHERE email = 'nasir.hossain@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Farhan Islam',
    role = 'owner',
    phone = '+8801512345682',
    company_name = 'Dhaka Football Club',
    city = 'Dhaka',
    address = 'Saheb Bazar, Dhaka'
WHERE email = 'farhan.islam@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Shakib Hassan',
    role = 'owner',
    phone = '+8801412345683',
    company_name = 'Dhaka Sports Arena',
    city = 'Dhaka',
    address = 'Band Road, Dhaka'
WHERE email = 'shakib.hassan@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Tamim Iqbal',
    role = 'owner',
    phone = '+8801312345684',
    company_name = 'Dhaka Football Ground',
    city = 'Dhaka',
    address = 'Choto Bazar, Dhaka'
WHERE email = 'tamim.iqbal@example.com';



















-- 1. Venue for Karim Ahmed (Dhaka)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Dhanmondi Football Arena', 
    'Professional standard football ground with FIFA approved grass. Perfect for tournaments and league matches. Modern facilities with excellent drainage system.',
    'House 32, Road 7, Dhanmondi, Dhaka-1205', 'Dhaka', 2500.00, 500.00, 22, '100m x 60m',
    ARRAY['Floodlights', 'Changing Rooms', 'Parking', 'Security', 'Washrooms', 'Water Supply', 'First Aid', 'Canteen', 'WiFi'],
    4.7, 'active',
    ARRAY[
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800'
       
    ]
FROM public.user_profiles up
WHERE up.email = 'karim.ahmed@example.com' AND up.role = 'owner';

-- 2. Venue for Rahim Khan (Chittagong)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Port City Football Stadium',
    'Large capacity football stadium with modern facilities. Host to many regional tournaments. VIP seating area available.',
    'Agrabad Commercial Area, Chittagong-4100', 'Chittagong', 3000.00, 600.00, 30, '105m x 68m',
    ARRAY['Professional Floodlights', 'VIP Changing Rooms', 'Covered Parking', '24/7 Security', 'Medical Room', 'Cafeteria', 'Sound System', 'VIP Lounge'],
    4.8, 'active',
    ARRAY[
        'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800'
     
    ]
FROM public.user_profiles up
WHERE up.email = 'rahim.khan@example.com' AND up.role = 'owner';

-- 3. Venue for Salim Uddin (Sylhet)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Sylhet Sports Complex',
    'Multi-purpose sports complex with a dedicated football ground. Great for both practice and matches. Beautiful mountain view surroundings.',
    'Chowhatta, Sylhet-3100', 'Sylhet', 1500.00, 300.00, 22, '95m x 60m',
    ARRAY['Floodlights', 'Changing Rooms', 'Parking', 'Washrooms', 'Refreshment Corner', 'Equipment Storage'],
    4.3, 'active',
    ARRAY[
     
        'https://images.unsplash.com/photo-1552667466-07770ae110d0?w=800'
       
    ]
FROM public.user_profiles up
WHERE up.email = 'salim.uddin@example.com' AND up.role = 'owner';

-- 4. Venue for Nasir Hossain (Comilla)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Comilla Football Ground',
    'Well-maintained football ground in the heart of Comilla. Great for local tournaments and practice sessions. Community favorite ground.',
    'Ranir Bazar, Comilla-3500', 'Comilla', 1200.00, 250.00, 22, '90m x 55m',
    ARRAY['Basic Lighting', 'Changing Room', 'Parking', 'Water Supply', 'Security', 'Seating Area'],
    4.1, 'active',
    ARRAY[
        
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800'
     
    ]
FROM public.user_profiles up
WHERE up.email = 'nasir.hossain@example.com' AND up.role = 'owner';

-- 5. Venue for Farhan Islam (Rajshahi)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Rajshahi Premier Ground',
    'Modern football facility in the silk city. Known for hosting inter-district tournaments. Well-maintained turf with proper markings.',
    'Saheb Bazar Zero Point, Rajshahi-6000', 'Rajshahi', 1800.00, 350.00, 22, '98m x 62m',
    ARRAY['Floodlights', 'Player Lounge', 'Parking', 'Security', 'Washrooms', 'Scoreboard', 'Equipment Room'],
    4.4, 'active',
    ARRAY[
        'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800'
  
    ]
FROM public.user_profiles up
WHERE up.email = 'farhan.islam@example.com' AND up.role = 'owner';

-- 6. Venue for Shakib Hassan (Barisal)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Barisal River View Stadium',
    'Scenic football ground with river view. Popular venue for weekend matches. Natural grass field with modern amenities.',
    'Band Road, Barisal-8200', 'Barisal', 1400.00, 280.00, 22, '92m x 58m',
    ARRAY['Natural Lighting', 'Changing Rooms', 'River View Seating', 'Parking', 'Refreshment Stall', 'Washrooms'],
    4.2, 'active',
    ARRAY[
        'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=800'
     
    ]
FROM public.user_profiles up
WHERE up.email = 'shakib.hassan@example.com' AND up.role = 'owner';

-- 7. Venue for Tamim Iqbal (Mymensingh)
INSERT INTO public.venues (
    owner_id, name, description, address, city, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Mymensingh Central Ground',
    'Historic football ground in the education city. Home to many local clubs. Traditional grass field with modern upgrades.',
    'Choto Bazar, Mymensingh-2200', 'Mymensingh', 1300.00, 260.00, 22, '88m x 56m',
    ARRAY['Traditional Floodlights', 'Classic Changing Room', 'Open Parking', 'Basic Amenities', 'Water Point'],
    4.0, 'active',
    ARRAY[
        'https://images.unsplash.com/photo-1552318965-6e6be7484ada?w=800'
    
 
    ]
FROM public.user_profiles up
WHERE up.email = 'tamim.iqbal@example.com' AND up.role = 'owner';

-- Also update Tasnuva's venue with images
UPDATE public.venues SET 
    image_urls = ARRAY[
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800'

    ]
WHERE owner_id = (SELECT id FROM public.user_profiles WHERE email = 'tasnuvaislam.me@gmail.com');

-- Verify all created venues with images
SELECT 
    up.full_name as owner_name,
    up.company_name,
    up.city as owner_city,
    v.name as venue_name,
    v.price_per_hour,
    v.rating,
    v.status,
    array_length(v.image_urls, 1) as image_count
FROM public.user_profiles up
JOIN public.venues v ON up.id = v.owner_id
WHERE up.role = 'owner'
ORDER BY v.price_per_hour DESC;

-- Test the functions with all venues
SELECT 'All Public Venues with Images:' as info;
SELECT name, city, price_per_hour, rating, image_urls FROM get_public_venues();