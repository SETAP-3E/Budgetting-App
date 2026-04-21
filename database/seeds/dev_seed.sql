-- Development seed data
-- Inserts the 5 predefined system categories (user_id = NULL).
-- colour_value is the Flutter ARGB integer matching the frontend theme palette.

INSERT INTO categories (id, user_id, name, icon, colour_value, is_predefined)
VALUES
    (gen_random_uuid(), NULL, 'Groceries',     'shopping_bag',       4280420146, TRUE),
    (gen_random_uuid(), NULL, 'Utilities',     'electrical_services', 4288185516, TRUE),
    (gen_random_uuid(), NULL, 'Entertainment', 'sports_esports',      4294945792, TRUE),
    (gen_random_uuid(), NULL, 'Dining Out',    'restaurant',          4294956295, TRUE),
    (gen_random_uuid(), NULL, 'Transport',     'directions_car',      4285532778, TRUE)
ON CONFLICT DO NOTHING;
