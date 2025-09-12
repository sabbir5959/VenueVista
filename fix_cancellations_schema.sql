-- Migration script to fix cancellations table schema
-- Run this in your Supabase SQL editor to allow NULL values

-- First, check if the table exists and see current constraints
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'cancellations'
AND column_name IN ('cancellation_fee', 'refund_amount', 'refund_status')
ORDER BY ordinal_position;

-- Drop the table if it exists (this will recreate it with correct schema)
-- WARNING: This will delete all existing data
DROP TABLE IF EXISTS public.cancellations CASCADE;

-- Recreate the table with the correct schema
CREATE TABLE public.cancellations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Reference to the original booking
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  
  -- User information
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Booking details (stored for historical purposes)
  venue_id UUID REFERENCES public.venues(id) ON DELETE SET NULL,
  venue_name TEXT NOT NULL,
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  
  -- Financial information
  original_amount DECIMAL(10, 2) NOT NULL, -- Calculated from venue price_per_hour * hours
  cancellation_fee DECIMAL(10, 2) DEFAULT 0,  -- Set to 0 as requested
  refund_amount DECIMAL(10, 2) DEFAULT 0,     -- Set to 0 as requested
  
  -- Cancellation details
  cancellation_reason TEXT,
  cancelled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL, -- NULL as requested
  
  -- Processing status
  refund_status VARCHAR(20) DEFAULT 'pending' CHECK (refund_status IN ('pending', 'processing', 'completed', 'failed', NULL)),
  refund_processed_at TIMESTAMP WITH TIME ZONE,
  
  -- Administrative fields
  processed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- For admin processing
  admin_notes TEXT DEFAULT NULL, -- NULL as requested
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_cancellations_user_id ON public.cancellations(user_id);
CREATE INDEX idx_cancellations_booking_id ON public.cancellations(booking_id);
CREATE INDEX idx_cancellations_venue_id ON public.cancellations(venue_id);
CREATE INDEX idx_cancellations_cancelled_at ON public.cancellations(cancelled_at);
CREATE INDEX idx_cancellations_refund_status ON public.cancellations(refund_status);

-- Add RLS (Row Level Security) policies
ALTER TABLE public.cancellations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own cancellations
CREATE POLICY "Users can view their own cancellations" ON public.cancellations
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can only insert their own cancellations
CREATE POLICY "Users can insert their own cancellations" ON public.cancellations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_cancellations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic timestamp update
CREATE TRIGGER trigger_update_cancellations_updated_at
  BEFORE UPDATE ON public.cancellations
  FOR EACH ROW
  EXECUTE FUNCTION update_cancellations_updated_at();

-- Create a view for easy cancellation reporting
CREATE VIEW public.cancellation_summary AS
SELECT 
  c.*,
  NULL as venue_name_current, -- Set to NULL as requested
  v.address as venue_address,
  u.email as user_email
FROM public.cancellations c
LEFT JOIN public.venues v ON c.venue_id = v.id
LEFT JOIN auth.users u ON c.user_id = u.id;

-- Grant necessary permissions
GRANT SELECT, INSERT ON public.cancellations TO authenticated;
GRANT SELECT ON public.cancellation_summary TO authenticated;

-- Verify the schema is correct
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'cancellations'
ORDER BY ordinal_position;
