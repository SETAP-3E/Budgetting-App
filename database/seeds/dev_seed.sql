-- Development seed data
-- Inserts the 5 predefined system categories (user_id = NULL).
-- colour_value is the Flutter ARGB integer matching the frontend theme palette.

INSERT INTO categories (id, user_id, name, icon, colour_value, is_predefined)
VALUES
    (gen_random_uuid(), NULL, 'Groceries',     'shopping_bag',        4280420146, TRUE),
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
INSERT INTO accounts
    (id, user_id, name, currency, account_type, balance, monthly_budget, accent_color)
VALUES
    (
        '00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000001',
        'Main Current Account', 'GBP', 'current',
        1842.76, 1800.00, 4283283116  -- Color(0xFF4DB6AC) teal
    ),
    (
        '00000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000001',
        'Savings Pot', 'GBP', 'savings',
        5200.00, 600.00, 4284922730  -- Color(0xFF66BB6A) green
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000001',
        'Joint Bills Account', 'GBP', 'joint',
        963.45, 1100.00, 4294951175  -- Color(0xFFFFC107) amber
    ),
    (
        '00000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000001',
        'Trip Savings', 'GBP', 'savings',
        1375.20, 300.00, 4294940672  -- Color(0xFFFF9800) orange
    )
ON CONFLICT DO NOTHING;

-- Monthly budget goals for dev user.
-- May 2026 (current month).
INSERT INTO budgets
    (user_id, category_id, period_year, period_month, goal_amount)
SELECT
    '00000000-0000-0000-0000-000000000001'::uuid,
    c.id, 2026, 5, v.goal
FROM (VALUES
    ('Groceries',     300.00::numeric),
    ('Utilities',     150.00::numeric),
    ('Entertainment', 200.00::numeric),
    ('Dining Out',    200.00::numeric),
    ('Transport',     150.00::numeric)
) AS v(name, goal)
JOIN categories c ON c.name = v.name AND c.is_predefined = TRUE
ON CONFLICT DO NOTHING;

-- April 2026 (last month).
INSERT INTO budgets
    (user_id, category_id, period_year, period_month, goal_amount)
SELECT
    '00000000-0000-0000-0000-000000000001'::uuid,
    c.id, 2026, 4, v.goal
FROM (VALUES
    ('Groceries',     300.00::numeric),
    ('Utilities',     150.00::numeric),
    ('Entertainment', 200.00::numeric),
    ('Dining Out',    200.00::numeric),
    ('Transport',     150.00::numeric)
) AS v(name, goal)
JOIN categories c ON c.name = v.name AND c.is_predefined = TRUE
ON CONFLICT DO NOTHING;

-- Transactions: May 2026 (mid-month, partially spent).
INSERT INTO transactions
    (user_id, account_id, category_id, amount, description, transaction_date)
SELECT
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid,
    c.id, v.amount::numeric, v.description, v.txn_date::date
FROM (VALUES
    ('Groceries',     45.30, 'Tesco',           '2026-05-02'),
    ('Groceries',     62.15, 'Sainsbury''s',     '2026-05-07'),
    ('Groceries',     38.90, 'Lidl',             '2026-05-10'),
    ('Transport',     25.00, 'Monthly bus pass', '2026-05-01'),
    ('Transport',     12.40, 'Tube fares',       '2026-05-06'),
    ('Dining Out',    32.50, 'Nandos',           '2026-05-04'),
    ('Dining Out',    18.75, 'Pret a Manger',    '2026-05-09'),
    ('Entertainment', 14.99, 'Netflix',          '2026-05-01'),
    ('Entertainment', 45.00, 'Cinema',           '2026-05-08')
) AS v(cat, amount, description, txn_date)
JOIN categories c ON c.name = v.cat AND c.is_predefined = TRUE;

-- Transactions: April 2026 (near-limit; Entertainment over budget).
INSERT INTO transactions
    (user_id, account_id, category_id, amount, description, transaction_date)
SELECT
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid,
    c.id, v.amount::numeric, v.description, v.txn_date::date
FROM (VALUES
    ('Groceries',      78.20, 'Tesco',            '2026-04-03'),
    ('Groceries',      55.40, 'Waitrose',          '2026-04-10'),
    ('Groceries',      88.60, 'Sainsbury''s',      '2026-04-17'),
    ('Groceries',      65.30, 'Top-up shop',       '2026-04-24'),
    ('Utilities',      95.00, 'Electricity bill',  '2026-04-05'),
    ('Utilities',      48.50, 'Gas bill',          '2026-04-05'),
    ('Transport',      25.00, 'Monthly bus pass',  '2026-04-01'),
    ('Transport',      48.90, 'Train tickets',     '2026-04-15'),
    ('Transport',      58.20, 'Petrol',            '2026-04-20'),
    ('Dining Out',     45.00, 'Restaurant',        '2026-04-12'),
    ('Dining Out',     89.50, 'Birthday meal',     '2026-04-18'),
    ('Dining Out',     55.75, 'Work lunch',        '2026-04-22'),
    ('Entertainment',  14.99, 'Netflix',           '2026-04-01'),
    ('Entertainment',  89.99, 'Concert tickets',   '2026-04-08'),
    ('Entertainment', 120.00, 'Sports equipment',  '2026-04-25')
) AS v(cat, amount, description, txn_date)
JOIN categories c ON c.name = v.cat AND c.is_predefined = TRUE;
