**TECH STACK**

PostgreSQL DataBase
Dart / Flutter for app / webapp
Dart Frog for backend API server

**THINGS TO REMEMBER**

If changes needed on current plan, provide rational in documentation

**UNIT TESTS REQUIRED**

100% coverage on unit tests for each item

**INITIAL PLAN**

Just get something written, some vague start to project

**DEPLOYMENT**

Dockerised — docker compose up --build starts all three services:
- postgres:16-alpine on :5432
- Dart Frog backend on :8080
- Flutter web (nginx) on :80

**ARCHITECTURE**

Three-layer backend (routes → services → repositories). Each layer is independently testable:
- Routes: thin handlers, delegate to one service method
- Services: all business logic, depend on repository interfaces (not concrete classes)
- Repositories: all SQL, implement abstract interfaces — mockable for unit tests

Flutter frontend uses feature-based vertical slices:
- Each feature owns data / domain / presentation layers
- State management: BLoC (flutter_bloc)
- Router: go_router
- HTTP client: dio (wrapped in core/api/)

**ARCHITECTURE CHANGE LOG**

2026-03-19 — Chose Dart Frog over raw Shelf for backend. Rationale: file-system routing reduces boilerplate, built-in test helpers make 100% coverage more achievable, CLI tooling (dart_frog dev) improves DX for small team.

2026-03-19 — Chose BLoC (flutter_bloc) over Riverpod for state management. Rationale: explicit event/state separation makes unit testing with bloc_test straightforward; aligns with 100% coverage requirement.

**FILE STRUCTURE**

```
Budgetting-App/
├── docker-compose.yml
├── docker-compose.override.yml
├── .env.example
├── .gitignore
│
├── database/
│   ├── migrations/
│   │   ├── 0001_create_users.sql
│   │   ├── 0002_create_accounts.sql
│   │   ├── 0003_create_categories.sql
│   │   ├── 0004_create_transactions.sql
│   │   └── 0005_create_budgets.sql
│   ├── seeds/
│   │   └── dev_seed.sql
│   └── schema.sql
│
├── backend/                         # Dart Frog API
│   ├── Dockerfile
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── routes/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── accounts/
│   │   ├── transactions/
│   │   ├── budgets/
│   │   └── categories/
│   ├── lib/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── middleware/
│   │   ├── db/
│   │   └── utils/
│   └── test/
│       ├── routes/
│       ├── services/
│       ├── repositories/
│       ├── middleware/
│       └── utils/
│
├── frontend/                        # Flutter (mobile + web)
│   ├── Dockerfile
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── web/
│   │   └── index.html
│   ├── lib/
│   │   ├── core/
│   │   │   ├── api/
│   │   │   ├── auth/
│   │   │   ├── router/
│   │   │   ├── theme/
│   │   │   └── utils/
│   │   └── features/
│   │       ├── auth/
│   │       ├── dashboard/
│   │       ├── accounts/
│   │       ├── transactions/
│   │       ├── budgets/
│   │       └── reports/
│   │           each: data/ | domain/models/ | domain/usecases/
│   │                 presentation/bloc/ | screens/ | widgets/
│   └── test/
│       ├── core/
│       └── features/
│
└── nginx/
    └── nginx.conf
```
