-- Test script to validate cancellation system functionality
-- Run this directly in your Supabase SQL editor

-- 1. Check if cancellations table exists with correct structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'cancellations'
ORDER BY ordinal_position;

-- 2. Check if cancellation_summary view exists
SELECT schemaname, viewname, definition
FROM pg_views 
WHERE viewname = 'cancellation_summary';

-- 3. Test inserting a sample cancellation record with NULL values
INSERT INTO cancellations (
    booking_id,
    user_id,
    venue_id,
    cancelled_at,
    cancellation_reason,
    cancellation_fee,
    refund_amount,
    refund_status
) VALUES (
    '00000000-0000-0000-0000-000000000000'::uuid, -- placeholder booking_id
    auth.uid(), -- current user
    '00000000-0000-0000-0000-000000000000'::uuid, -- placeholder venue_id
    NOW(),
    'Testing cancellation with NULL processing fields',
    NULL, -- cancellation_fee should be NULL
    NULL, -- refund_amount should be NULL
    NULL  -- refund_status should be NULL
) ON CONFLICT DO NOTHING; -- In case test record already exists

-- 4. Verify the test record was inserted with NULL values
SELECT 
    id,
    cancellation_reason,
    cancellation_fee,
    refund_amount,
    refund_status,
    cancelled_at
FROM cancellations 
WHERE cancellation_reason LIKE 'Testing cancellation%'
ORDER BY cancelled_at DESC
LIMIT 1;

-- 5. Test cancellation_summary view functionality
SELECT * FROM cancellation_summary 
WHERE cancellation_reason LIKE 'Testing cancellation%'
ORDER BY cancelled_at DESC
LIMIT 1;

-- 6. Clean up test record
DELETE FROM cancellations 
WHERE cancellation_reason LIKE 'Testing cancellation%';
