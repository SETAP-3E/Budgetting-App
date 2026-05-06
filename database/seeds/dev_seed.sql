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

-- Dev accounts for the dev user (IDs mirrored in MockAccountsDatasource).
-- accent_color values are Flutter ARGB integers (Color.toARGB32()).
INSERT INTO accounts (id, user_id, name, currency, account_type, balance, monthly_budget, accent_color)
VALUES
    (
        '00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000001',
        'Main Current Account',
        'GBP',
        'current',
        1842.76,
        1800.00,
        4283283116   -- Color(0xFF4DB6AC) teal
    ),
    (
        '00000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000001',
        'Savings Pot',
        'GBP',
        'savings',
        5200.00,
        600.00,
        4284922730   -- Color(0xFF66BB6A) green
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000001',
        'Joint Bills Account',
        'GBP',
        'joint',
        963.45,
        1100.00,
        4294951175   -- Color(0xFFFFC107) amber
    ),
    (
        '00000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000001',
        'Trip Savings',
        'GBP',
        'savings',
        1375.20,
        300.00,
        4294940672   -- Color(0xFFFF9800) orange
    )
ON CONFLICT DO NOTHING;
