-- Create cancellations table for storing booking cancellation information
CREATE TABLE cancellations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Reference to the original booking
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  
  -- User information
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Booking details (stored for historical purposes)
  venue_id UUID REFERENCES venues(id) ON DELETE SET NULL,
  venue_name TEXT NOT NULL,
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  
  -- Financial information
  original_amount DECIMAL(10, 2) NOT NULL,
  cancellation_fee DECIMAL(10, 2) DEFAULT NULL,
  refund_amount DECIMAL(10, 2) DEFAULT NULL,
  
  -- Cancellation details
  cancellation_reason TEXT,
  cancelled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Processing status
  refund_status VARCHAR(20) DEFAULT NULL CHECK (refund_status IN ('pending', 'processing', 'completed', 'failed', NULL)),
  refund_processed_at TIMESTAMP WITH TIME ZONE,
  
  -- Administrative fields
  processed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- For admin processing
  admin_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_cancellations_user_id ON cancellations(user_id);
CREATE INDEX idx_cancellations_booking_id ON cancellations(booking_id);
CREATE INDEX idx_cancellations_venue_id ON cancellations(venue_id);
CREATE INDEX idx_cancellations_cancelled_at ON cancellations(cancelled_at);
CREATE INDEX idx_cancellations_refund_status ON cancellations(refund_status);

-- Add RLS (Row Level Security) policies
ALTER TABLE cancellations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own cancellations
CREATE POLICY "Users can view their own cancellations" ON cancellations
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can only insert their own cancellations
CREATE POLICY "Users can insert their own cancellations" ON cancellations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can update cancellations (for processing)
-- Note: Remove this policy if you don't have admin role management yet
-- CREATE POLICY "Admins can update cancellations" ON cancellations
--   FOR UPDATE USING (
--     EXISTS (
--       SELECT 1 FROM user_roles 
--       WHERE user_id = auth.uid() AND role = 'admin'
--     )
--   );

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
  BEFORE UPDATE ON cancellations
  FOR EACH ROW
  EXECUTE FUNCTION update_cancellations_updated_at();

-- Optional: Create a view for easy cancellation reporting
CREATE VIEW cancellation_summary AS
SELECT 
  c.*,
  v.name as venue_name_current,
  v.address as venue_address,
  u.email as user_email
FROM cancellations c
LEFT JOIN venues v ON c.venue_id = v.id
LEFT JOIN auth.users u ON c.user_id = u.id;

-- Grant necessary permissions
GRANT SELECT, INSERT ON cancellations TO authenticated;
GRANT SELECT ON cancellation_summary TO authenticated;
