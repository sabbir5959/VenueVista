-- Safer migration - only alters columns to allow NULL values
-- Use this if you have existing data you want to preserve

-- Alter the columns to allow NULL values and set default
ALTER TABLE cancellations 
ALTER COLUMN cancellation_fee DROP NOT NULL,
ALTER COLUMN cancellation_fee SET DEFAULT NULL;

ALTER TABLE cancellations 
ALTER COLUMN refund_amount DROP NOT NULL,
ALTER COLUMN refund_amount SET DEFAULT NULL;

ALTER TABLE cancellations 
ALTER COLUMN refund_status DROP NOT NULL,
ALTER COLUMN refund_status SET DEFAULT NULL;

-- Verify the changes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'cancellations'
AND column_name IN ('cancellation_fee', 'refund_amount', 'refund_status')
ORDER BY ordinal_position;
