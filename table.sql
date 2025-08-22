-- VenueVista Database Setup
-- Run this after auth_setup.sql

-- 1. Venues Table
CREATE TABLE IF NOT EXISTS public.venues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  address TEXT,
  city TEXT,
  price_per_hour DECIMAL(10,2) NOT NULL,
  ground_payment DECIMAL(10,2) DEFAULT 0,
  courts_count INTEGER DEFAULT 1,
  capacity INTEGER,
  ground_size TEXT,
  venue_type VARCHAR(50) DEFAULT 'football' CHECK (venue_type IN ('football','futsal','multi-sport')),
  facilities TEXT[],
  rating DECIMAL(2,1) DEFAULT 0.0,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive','maintenance')),
  maintenance_reason TEXT,
  maintenance_start DATE,
  maintenance_end DATE,
  image_urls TEXT[],
  total_bookings INTEGER DEFAULT 0,
  monthly_bookings INTEGER DEFAULT 0,
  revenue DECIMAL(15,2) DEFAULT 0,
  commission DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id),
  venue_id UUID NOT NULL REFERENCES public.venues(id),
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_hours DECIMAL(3,1) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  ground_payment DECIMAL(10,2) DEFAULT 0,
  transaction_fee DECIMAL(10,2) DEFAULT 10,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','confirmed','completed','cancelled','cancel_request')),
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','refunded')),
  payment_method VARCHAR(50),
  transaction_id VARCHAR(100),
  cancellation_reason TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

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
  status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('upcoming','registration_open','registration_closed','active','completed','cancelled')),
  player_format VARCHAR(10),
  image_url TEXT,
  location TEXT,
  organizer_name TEXT,
  organizer_phone VARCHAR(15),
  organizer_email TEXT,
  revenue DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tournament Registrations Table
CREATE TABLE IF NOT EXISTS public.tournament_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id),
  team_name TEXT NOT NULL,
  captain_name TEXT NOT NULL,
  captain_phone VARCHAR(15),
  captain_email TEXT,
  players_count INTEGER NOT NULL,
  registration_fee DECIMAL(10,2) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','refunded')),
  payment_method VARCHAR(50),
  transaction_id VARCHAR(100),
  status VARCHAR(20) DEFAULT 'registered' CHECK (status IN ('registered','confirmed','cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id VARCHAR(20) UNIQUE NOT NULL,
  user_id UUID REFERENCES public.user_profiles(id),
  booking_id UUID REFERENCES public.bookings(id),
  tournament_id UUID REFERENCES public.tournaments(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_type VARCHAR(50) NOT NULL CHECK (payment_type IN ('booking','tournament','refund','commission','cash_to_owner','equipment_rental')),
  payment_direction VARCHAR(20) NOT NULL CHECK (payment_direction IN ('from_user','to_owner','refund')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','completed','failed','processing')),
  payment_method VARCHAR(50) NOT NULL,
  transaction_id VARCHAR(100),
  description TEXT,
  person_name TEXT,
  person_contact VARCHAR(15),
  venue_name TEXT,
  refund_reason TEXT,
  processing_fee DECIMAL(10,2) DEFAULT 0,
  notes TEXT,
  recorded_by UUID REFERENCES public.user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

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

-- 7. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL CHECK (type IN ('booking','payment','tournament','system','promotional')),
  reference_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Pricing Rules Table
CREATE TABLE IF NOT EXISTS public.pricing_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
  rule_name TEXT NOT NULL,
  rule_type VARCHAR(50) NOT NULL CHECK (rule_type IN ('peak_hours','weekend','holiday','seasonal')),
  multiplier DECIMAL(3,2) NOT NULL DEFAULT 1.0,
  start_date DATE,
  end_date DATE,
  start_time TIME,
  end_time TIME,
  days_of_week INTEGER[],
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for all tables
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_rules ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Venues policies
CREATE POLICY "Venues viewable by everyone" ON public.venues FOR SELECT USING (true);
CREATE POLICY "Venue owners can manage their venues" ON public.venues FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "Admins can manage all venues" ON public.venues FOR ALL USING (
  EXISTS (SELECT 1 FROM public.user_profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Bookings policies
CREATE POLICY "Users can view their bookings" ON public.bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Venue owners can view bookings for their venues" ON public.bookings FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.venues WHERE id = venue_id AND owner_id = auth.uid())
);
CREATE POLICY "Admins can view all bookings" ON public.bookings FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.user_profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Tournaments policies
CREATE POLICY "Tournaments viewable by everyone" ON public.tournaments FOR SELECT USING (true);
CREATE POLICY "Organizers can manage their tournaments" ON public.tournaments FOR ALL USING (auth.uid() = organizer_id);

-- Add indexes for better performance
CREATE INDEX idx_venues_owner_id ON public.venues(owner_id);
CREATE INDEX idx_venues_status ON public.venues(status);
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_venue_id ON public.bookings(venue_id);
CREATE INDEX idx_bookings_date ON public.bookings(booking_date);
CREATE INDEX idx_tournaments_date ON public.tournaments(tournament_date);
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- Triggers for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON public.venues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tournaments_updated_at BEFORE UPDATE ON public.tournaments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();