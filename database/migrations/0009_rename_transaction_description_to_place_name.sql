-- Rename the transactions.description column to place_name to better reflect
-- that it stores a Google Places display name rather than a free-text note.
ALTER TABLE transactions
  RENAME COLUMN description TO place_name;
