
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  full_name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone character varying,
  role character varying NOT NULL DEFAULT 'user'::character varying CHECK (role::text = ANY (ARRAY['admin'::character varying, 'owner'::character varying, 'user'::character varying]::text[])),
  status character varying NOT NULL DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'suspended'::character varying]::text[])),
  company_name text,
  avatar_url text,
  city text,
  address text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);














CREATE TABLE public.venues (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  address text,
  city text,
  price_per_hour numeric NOT NULL,
  ground_payment numeric DEFAULT 0,
  capacity integer,
  ground_size text,
  venue_type character varying DEFAULT 'football'::character varying CHECK (venue_type::text = 'football'::text),
  facilities ARRAY,
  rating numeric DEFAULT 0.0 CHECK (rating >= 0.0 AND rating <= 5.0),
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'maintenance'::character varying, 'owner_suspended'::character varying]::text[])),
  maintenance_reason text,
  maintenance_start date,
  maintenance_end date,
  image_urls ARRAY,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  area text,
  CONSTRAINT venues_pkey PRIMARY KEY (id),
  CONSTRAINT venues_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.user_profiles(id)
);

-- Update dummy owner profiles
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
    company_name = 'Club Volta',
    city = 'Dhaka',
    address = 'ECB'
WHERE email = 'rahim.khan@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Salim Uddin',
    role = 'owner',
    phone = '+8801912345680',
    company_name = 'Sports Arena',
    city = 'Dhaka',
    address = 'Pallabi, Dhaka'
WHERE email = 'salim.uddin@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Nasir Hossain',
    role = 'owner',
    phone = '+8801612345681',
    company_name = 'Sports Club',
    city = 'Dhaka',
    address = 'Mirpur 12, Dhaka'
WHERE email = 'nasir.hossain@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Farhan Islam',
    role = 'owner',
    phone = '+8801512345682',
    company_name = 'Football Club',
    city = 'Dhaka',
    address = 'Mirpur 10, Dhaka'
WHERE email = 'farhan.islam@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Shakib Hassan',
    role = 'owner',
    phone = '+8801412345683',
    company_name = 'Kings Arena',
    city = 'Dhaka',
    address = 'Bashundhara'
WHERE email = 'shakib.hassan@example.com';

UPDATE public.user_profiles SET 
    full_name = 'Tamim Iqbal',
    role = 'owner',
    phone = '+8801312345684',
    company_name = 'Football Ground',
    city = 'Dhaka',
    address = 'Uttara Utoor, Dhaka'
WHERE email = 'tamim.iqbal@example.com';


-- 1. Venue for Karim Ahmed (Dhanmondi area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Dhanmondi Football Arena', 
    'Premium football ground in the heart of Dhanmondi. FIFA standard grass field with modern facilities.',
    'House 32, Road 7, Dhanmondi', 'Dhaka', 'Dhanmondi', 2500.00, 500.00, 22, '100m x 60m',
    ARRAY['Floodlights', 'Changing Rooms', 'Parking', 'Security', 'Washrooms', 'Water Supply', 'First Aid', 'Canteen'],
    4.7, 'active',
    ARRAY['https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800']
FROM public.user_profiles up
WHERE up.email = 'karim.ahmed@example.com';

-- 2. Venue for Rahim Khan (Cantonment area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Cantonment Sports Complex',
    'Military-grade football facility with excellent security and maintenance standards.',
    'ECB Cantonment Area', 'Dhaka', 'Cantonment', 3000.00, 600.00, 30, '105m x 68m',
    ARRAY['Professional Floodlights', 'VIP Changing Rooms', 'Secured Parking', '24/7 Security', 'Medical Room', 'Cafeteria'],
    4.8, 'active',
    ARRAY['https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800']
FROM public.user_profiles up
WHERE up.email = 'rahim.khan@example.com';

-- 3. Venue for Salim Uddin (Mirpur area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Pallabi Sports Ground',
    'Community-focused sports complex serving the Mirpur-Pallabi area with quality facilities.',
    'Section 13, Pallabi', 'Dhaka', 'Mirpur', 1800.00, 350.00, 22, '95m x 60m',
    ARRAY['Floodlights', 'Changing Rooms', 'Community Parking', 'Washrooms', 'Refreshment Corner'],
    4.3, 'active',
    ARRAY['https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800']
FROM public.user_profiles up
WHERE up.email = 'salim.uddin@example.com';

-- 4. Venue for Nasir Hossain (Mirpur area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Mirpur 12 Football Club',
    'Popular local football ground known for hosting weekend tournaments and community matches.',
    'Block C, Mirpur 12', 'Dhaka', 'Mirpur', 1500.00, 300.00, 22, '90m x 55m',
    ARRAY['Basic Lighting', 'Changing Room', 'Street Parking', 'Water Supply', 'Security'],
    4.1, 'active',
    ARRAY['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800']
FROM public.user_profiles up
WHERE up.email = 'nasir.hossain@example.com';

-- 5. Venue for Farhan Islam (Mirpur area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Mirpur 10 Stadium',
    'Well-maintained football stadium near Mirpur 10 roundabout. Great for competitive matches.',
    'Mirpur 10 Roundabout Area', 'Dhaka', 'Mirpur', 2000.00, 400.00, 22, '98m x 62m',
    ARRAY['Stadium Lighting', 'Player Lounge', 'Parking', 'Security', 'Washrooms', 'Scoreboard'],
    4.4, 'active',
    ARRAY['https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800']
FROM public.user_profiles up
WHERE up.email = 'farhan.islam@example.com';

-- 6. Venue for Shakib Hassan (Bashundhara area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Bashundhara Kings Arena',
    'Premium football facility in the upscale Bashundhara residential area with luxury amenities.',
    'Block J, Bashundhara R/A', 'Dhaka', 'Bashundhara', 2800.00, 550.00, 22, '102m x 65m',
    ARRAY['LED Floodlights', 'Premium Changing Rooms', 'VIP Parking', 'Security', 'Luxury Washrooms', 'Player Lounge'],
    4.6, 'active',
    ARRAY['https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=800']
FROM public.user_profiles up
WHERE up.email = 'shakib.hassan@example.com';

-- 7. Venue for Tamim Iqbal (Uttara area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Uttara Football Complex',
    'Modern football complex in Uttara serving the northern part of Dhaka with excellent facilities.',
    'Sector 13, Uttara', 'Dhaka', 'Uttara', 2200.00, 450.00, 22, '100m x 64m',
    ARRAY['Modern Lighting', 'Team Changing Rooms', 'Ample Parking', 'Security', 'First Aid', 'Equipment Room'],
    4.5, 'active',
    ARRAY['https://images.unsplash.com/photo-1552318965-6e6be7484ada?w=800']
FROM public.user_profiles up
WHERE up.email = 'tamim.iqbal@example.com';

-- Create venue for Tasnuva Islam (Gulshan area)
INSERT INTO public.venues (
    owner_id, name, description, address, city, area, price_per_hour, ground_payment,
    capacity, ground_size, facilities, rating, status, image_urls
) 
SELECT 
    up.id, 'Volta Football Arena',
    'Premium football ground managed by Club Volta. Professional standard turf with modern facilities.',
    'Gulshan-2, Dhaka-1212', 'Dhaka', 'Gulshan', 2000.00, 400.00, 22, '100m x 65m',
    ARRAY['Professional Lighting', 'Premium Changing Rooms', 'VIP Parking', 'Security', 'Washrooms', 'Water Supply', 'First Aid', 'Equipment Storage', 'WiFi'],
    4.5, 'active',
    ARRAY['https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800']
FROM public.user_profiles up
WHERE up.email = 'tasnuvaislam.me@gmail.com' AND up.role = 'owner';

-- Verify all created venues
SELECT 
    up.full_name as owner_name,
    up.company_name,
    v.name as venue_name,
    v.area as venue_area,
    v.price_per_hour,
    v.rating,
    v.status
FROM public.user_profiles up
JOIN public.venues v ON up.id = v.owner_id
WHERE up.role = 'owner'
ORDER BY v.price_per_hour DESC;









-- 2. Bookings Table (Your Simple Version)
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id),
  venue_id UUID NOT NULL REFERENCES public.venues(id),
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_hours DECIMAL(3,1) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Basic RLS Policies (যাতে restricted না দেখায়)
CREATE POLICY "Users can view their own bookings" ON public.bookings 
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookings" ON public.bookings 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Venue owners can view bookings for their venues" ON public.bookings 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.venues 
    WHERE venues.id = bookings.venue_id 
    AND venues.owner_id = auth.uid()
  )
);

-- Basic Index
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_venue_id ON public.bookings(venue_id);













-- 3. Tournaments Table
CREATE TABLE IF NOT EXISTS public.tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id VARCHAR(20) UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  venue_id UUID REFERENCES public.venues(id),
  organizer_id UUID REFERENCES public.user_profiles(id),
  tournament_date DATE NOT NULL,
  start_time TIME NOT NULL,
  duration_hours INTEGER NOT NULL,
  team_size INTEGER NOT NULL,
  max_teams INTEGER NOT NULL,
  registered_teams INTEGER DEFAULT 0,
  entry_fee DECIMAL(10,2) NOT NULL,
  first_prize DECIMAL(10,2),
  second_prize DECIMAL(10,2),
  third_prize DECIMAL(10,2),
  player_format VARCHAR(10),
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tournaments
CREATE POLICY "Tournaments viewable by everyone" ON public.tournaments 
FOR SELECT USING (true);

CREATE POLICY "Organizers can create tournaments" ON public.tournaments 
FOR INSERT WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "Organizers can manage their tournaments" ON public.tournaments 
FOR UPDATE USING (auth.uid() = organizer_id);

CREATE POLICY "Organizers can delete their tournaments" ON public.tournaments 
FOR DELETE USING (auth.uid() = organizer_id);

CREATE POLICY "Venue owners can view tournaments at their venues" ON public.tournaments 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.venues 
    WHERE venues.id = tournaments.venue_id 
    AND venues.owner_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all tournaments" ON public.tournaments 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.role = 'admin'
  )
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_tournaments_organizer_id ON public.tournaments(organizer_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_venue_id ON public.tournaments(venue_id);
CREATE INDEX IF NOT EXISTS idx_tournaments_date ON public.tournaments(tournament_date);
CREATE INDEX IF NOT EXISTS idx_tournaments_entry_fee ON public.tournaments(entry_fee);

-- Verify table creation
SELECT 'Tournaments table created successfully!' as status;


-- Insert 5 dummy tournaments
INSERT INTO public.tournaments (
    tournament_id, name, description, venue_id, organizer_id, tournament_date, 
    start_time, duration_hours, team_size, max_teams, registered_teams, 
    entry_fee, first_prize, second_prize, third_prize, player_format, image_url
) VALUES

-- 1. Premium Tournament at Cantonment
(
    'TOURN001',
    'Dhaka Premier Football Championship',
    'Annual championship featuring the best teams from Dhaka. Professional referees and live streaming available.',
    (SELECT id FROM public.venues WHERE name = 'Cantonment Sports Complex'),
    (SELECT id FROM public.user_profiles WHERE email = 'rahim.khan@example.com'),
    '2025-09-15',
    '16:00:00',
    8,
    11,
    16,
    3,
    2500.00,
    50000.00,
    25000.00,
    15000.00,
    '8v8',
    'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800'
),

-- 2. Community Tournament at Dhanmondi
(
    'TOURN002',
    'Dhanmondi Weekend Cup',
    'Fun weekend tournament for local teams and football enthusiasts. Great prizes and refreshments included.',
    (SELECT id FROM public.venues WHERE name = 'Dhanmondi Football Arena'),
    (SELECT id FROM public.user_profiles WHERE email = 'karim.ahmed@example.com'),
    '2025-09-22',
    '14:00:00',
    6,
    7,
    12,
    5,
    1500.00,
    20000.00,
    12000.00,
    8000.00,
    '7v7',
    'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800'
),

-- 3. Youth Tournament at Mirpur
(
    'TOURN003',
    'Mirpur Youth Football Festival',
    'Special tournament for young players under 18. Focus on skill development and fair play.',
    (SELECT id FROM public.venues WHERE name = 'Mirpur 10 Stadium'),
    (SELECT id FROM public.user_profiles WHERE email = 'farhan.islam@example.com'),
    '2025-09-28',
    '09:00:00',
    10,
    11,
    8,
    2,
    800.00,
    15000.00,
    8000.00,
    5000.00,
    '7v7',
    'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800'
),

-- 4. Corporate Tournament at Bashundhara
(
    'TOURN004',
    'Corporate Football League',
    'Professional tournament for corporate teams. Network with other companies while enjoying competitive football.',
    (SELECT id FROM public.venues WHERE name = 'Bashundhara Kings Arena'),
    (SELECT id FROM public.user_profiles WHERE email = 'shakib.hassan@example.com'),
    '2025-10-05',
    '18:00:00',
    4,
    5,
    20,
    8,
    3000.00,
    75000.00,
    40000.00,
    20000.00,
    '8v8',
    'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=800'
),

-- 5. Quick Tournament at Uttara
(
    'TOURN005',
    'Uttara Friday Night Futsal',
    'Fast-paced futsal tournament every Friday night. Perfect for working professionals to unwind.',
    (SELECT id FROM public.venues WHERE name = 'Uttara Football Complex'),
    (SELECT id FROM public.user_profiles WHERE email = 'tamim.iqbal@example.com'),
    '2025-09-30',
    '20:00:00',
    3,
    5,
    10,
    6,
    1200.00,
    12000.00,
    7000.00,
    4000.00,
    '8v8',
    'https://images.unsplash.com/photo-1552318965-6e6be7484ada?w=800'
);

-- Verify inserted tournaments
SELECT 
    t.tournament_id,
    t.name,
    v.name as venue_name,
    up.full_name as organizer_name,
    t.tournament_date,
    t.entry_fee,
    t.first_prize,
    t.max_teams,
    t.registered_teams,
    t.player_format
FROM public.tournaments t
JOIN public.venues v ON t.venue_id = v.id
JOIN public.user_profiles up ON t.organizer_id = up.id
ORDER BY t.tournament_date;















-- 4. Tournament Registrations Table
CREATE TABLE IF NOT EXISTS public.tournament_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id),
  registration_fee DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tournament_registrations ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tournament registrations
CREATE POLICY "Users can view their own registrations" ON public.tournament_registrations 
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own registrations" ON public.tournament_registrations 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own registrations" ON public.tournament_registrations 
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Tournament organizers can view registrations for their tournaments" ON public.tournament_registrations 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.tournaments 
    WHERE tournaments.id = tournament_registrations.tournament_id 
    AND tournaments.organizer_id = auth.uid()
  )
);

CREATE POLICY "Venue owners can view registrations for tournaments at their venues" ON public.tournament_registrations 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.tournaments t
    JOIN public.venues v ON t.venue_id = v.id
    WHERE t.id = tournament_registrations.tournament_id 
    AND v.owner_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all registrations" ON public.tournament_registrations 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.role = 'admin'
  )
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_tournament_registrations_user_id ON public.tournament_registrations(user_id);
CREATE INDEX IF NOT EXISTS idx_tournament_registrations_tournament_id ON public.tournament_registrations(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_registrations_created_at ON public.tournament_registrations(created_at);

-- Add unique constraint to prevent duplicate registrations
ALTER TABLE public.tournament_registrations 
ADD CONSTRAINT unique_user_tournament_registration 
UNIQUE (tournament_id, user_id);

-- Verify table creation
SELECT 'Tournament registrations table created successfully!' as status;



















-- 5. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID REFERENCES public.user_profiles(id),
  booking_id UUID REFERENCES public.bookings(id),
  tournament_registration_id UUID REFERENCES public.tournament_registrations(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending','completed','failed','refunded')),
  transaction_reference VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for payments
CREATE POLICY "Users can view their own payments" ON public.payments 
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own payments" ON public.payments 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own payments" ON public.payments 
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Venue owners can view payments for bookings at their venues" ON public.payments 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.bookings b
    JOIN public.venues v ON b.venue_id = v.id
    WHERE b.id = payments.booking_id 
    AND v.owner_id = auth.uid()
  )
);

CREATE POLICY "Tournament organizers can view payments for their tournament registrations" ON public.payments 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.tournament_registrations tr
    JOIN public.tournaments t ON tr.tournament_id = t.id
    WHERE tr.id = payments.tournament_registration_id 
    AND t.organizer_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all payments" ON public.payments 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.role = 'admin'
  )
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON public.payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_tournament_registration_id ON public.payments(tournament_registration_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_payments_method ON public.payments(payment_method);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);

-- Add constraint to ensure payment is for either booking or tournament registration, not both
ALTER TABLE public.payments 
ADD CONSTRAINT check_payment_type 
CHECK (
  (booking_id IS NOT NULL AND tournament_registration_id IS NULL) OR
  (booking_id IS NULL AND tournament_registration_id IS NOT NULL)
);

-- Verify table creation
SELECT 'Payments table created successfully!' as status;















-- 6. Venue Reviews Table
CREATE TABLE IF NOT EXISTS public.venue_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id),
  booking_id UUID REFERENCES public.bookings(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(venue_id, user_id, booking_id)
);

-- Enable RLS
ALTER TABLE public.venue_reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies for venue reviews
CREATE POLICY "Anyone can view venue reviews" ON public.venue_reviews 
FOR SELECT USING (true);

CREATE POLICY "Users can create their own reviews" ON public.venue_reviews 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" ON public.venue_reviews 
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" ON public.venue_reviews 
FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Venue owners can view reviews for their venues" ON public.venue_reviews 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.venues 
    WHERE venues.id = venue_reviews.venue_id 
    AND venues.owner_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage all reviews" ON public.venue_reviews 
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.role = 'admin'
  )
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_venue_reviews_venue_id ON public.venue_reviews(venue_id);
CREATE INDEX IF NOT EXISTS idx_venue_reviews_user_id ON public.venue_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_venue_reviews_booking_id ON public.venue_reviews(booking_id);
CREATE INDEX IF NOT EXISTS idx_venue_reviews_rating ON public.venue_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_venue_reviews_created_at ON public.venue_reviews(created_at);

-- Function to update venue rating when review is added/updated/deleted
CREATE OR REPLACE FUNCTION update_venue_rating()
RETURNS TRIGGER AS $$
BEGIN
  -- Update the venue's rating based on all reviews
  UPDATE public.venues 
  SET rating = (
    SELECT ROUND(AVG(rating), 1)
    FROM public.venue_reviews 
    WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id)
  )
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update venue rating
CREATE TRIGGER trigger_update_venue_rating_on_insert
  AFTER INSERT ON public.venue_reviews
  FOR EACH ROW EXECUTE FUNCTION update_venue_rating();

CREATE TRIGGER trigger_update_venue_rating_on_update
  AFTER UPDATE ON public.venue_reviews
  FOR EACH ROW EXECUTE FUNCTION update_venue_rating();

CREATE TRIGGER trigger_update_venue_rating_on_delete
  AFTER DELETE ON public.venue_reviews
  FOR EACH ROW EXECUTE FUNCTION update_venue_rating();

-- Verify table creation
SELECT 'Venue reviews table created successfully!' as status;