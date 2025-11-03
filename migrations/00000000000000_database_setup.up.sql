-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Utility Functions
CREATE OR REPLACE FUNCTION updated_at_trigger()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE "plpgsql";
