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

-- Dev user (fixed UUID used by the frontend until real auth is implemented).
INSERT INTO users (id, email, password_hash, display_name)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'dev@example.com',
    '$2a$12$placeholder_hash_not_for_login',
    'Dev User'
) ON CONFLICT DO NOTHING;

-- Dev account for the dev user.
INSERT INTO accounts (id, user_id, name, currency)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000001',
    'Main Account',
    'GBP'
) ON CONFLICT DO NOTHING;
