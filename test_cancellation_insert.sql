-- Test script to verify cancellations table accepts NULL values
-- Run this AFTER running fix_cancellations_schema.sql

-- Test insertion with NULL values (this should work after migration)
INSERT INTO cancellations (
    id,
    booking_id,
    user_id,
    venue_id,
    venue_name,
    booking_date,
    start_time,
    end_time,
    original_amount,
    cancellation_fee,
    refund_amount,
    cancellation_reason,
    refund_status
) VALUES (
    uuid_generate_v4(),
    uuid_generate_v4(), -- dummy booking ID
    auth.uid(), -- current user
    uuid_generate_v4(), -- dummy venue ID
    'Test Venue',
    '2025-09-15',
    '10:00',
    '12:00',
    500.00,
    NULL, -- Should work now
    NULL, -- Should work now
    'Test cancellation',
    NULL  -- Should work now
);

-- Verify the insertion worked
SELECT * FROM cancellation_summary ORDER BY created_at DESC LIMIT 1;

-- Clean up test data
DELETE FROM cancellations WHERE venue_name = 'Test Venue';
