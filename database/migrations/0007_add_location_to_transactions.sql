-- Migration 0007: Add geolocation columns to transactions
-- Supports Places Autocomplete and the spending map in the Reports screen.
-- Both columns are nullable so all existing transactions are unaffected.

ALTER TABLE transactions
  ADD COLUMN latitude  DECIMAL(9,6),
  ADD COLUMN longitude DECIMAL(9,6);

-- Partial index only covers rows that actually have a location,
-- keeping it cheap for the majority of rows that have no coordinates.
CREATE INDEX transactions_location_idx
  ON transactions (user_id)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
