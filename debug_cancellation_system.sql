-- Test script to verify cancellations table works properly
-- Run this in Supabase SQL Editor to test the cancellation system

-- 1. Check if the cancellations table exists with correct schema
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'cancellations'
ORDER BY ordinal_position;

-- 2. Check if we have any existing bookings to test with
SELECT 
    id as booking_uuid,
    booking_id as booking_string_id,
    user_id,
    venue_id,
    booking_date,
    start_time,
    end_time
FROM bookings 
ORDER BY created_at DESC 
LIMIT 5;

-- 3. Check if we have any existing payments linked to bookings
SELECT 
    p.id as payment_id,
    p.booking_id,
    p.amount,
    b.booking_id as booking_string_id
FROM payments p
LEFT JOIN bookings b ON p.booking_id = b.id
ORDER BY p.created_at DESC
LIMIT 5;

-- 4. Test manual insertion (this should work now after migration)
-- Replace the UUIDs below with actual values from the queries above
/*
INSERT INTO cancellations (
    booking_id,
    user_id,
    venue_id,
    venue_name,
    booking_date,
    start_time,
    end_time,
    original_amount,
    cancellation_reason
) VALUES (
    '00000000-0000-0000-0000-000000000000', -- Replace with actual booking UUID
    auth.uid(), -- Current user
    '00000000-0000-0000-0000-000000000000', -- Replace with actual venue UUID
    'Test Venue',
    '2025-09-15',
    '10:00',
    '12:00',
    500.00,
    'Manual test cancellation'
);
*/

-- 5. Check cancellation_summary view
SELECT * FROM cancellation_summary ORDER BY created_at DESC LIMIT 10;
