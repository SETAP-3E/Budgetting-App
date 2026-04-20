# Budgetting App

UP2246628 - github.com/CameronGibbons

A full-stack budgeting application built with Flutter (frontend), Dart Frog (backend), and PostgreSQL (database).

---

## Tech Stack

| Layer    | Technology                              |
|----------|-----------------------------------------|
| Frontend | Flutter (web)                           |
| Backend  | Dart Frog REST API                      |
| Database | PostgreSQL 16                           |
| Infra    | Docker + Docker Compose                 |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) **or** [Colima](https://github.com/abiosoft/colima) (macOS)
- [Docker Compose](https://docs.docker.com/compose/) (v2 — `docker compose` subcommand)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for local development only)

---

## Running with Docker Compose (recommended)

### 1. Clone the repository

```bash
git clone https://github.com/CameronGibbons/Budgetting-App.git
cd Budgetting-App
```

### 2. Create your environment file

```bash
cp .env.example .env
```

Open `.env` and set secure values:

```env
POSTGRES_DB=budgetting
POSTGRES_USER=budgetting_user
POSTGRES_PASSWORD=your_secure_password_here

JWT_SECRET=your_long_random_secret_here
PORT=8080

API_BASE_URL=http://localhost:8080
```

> **Note:** Never commit `.env` to version control. It is already listed in `.gitignore`.

### 3. Start all services

```bash
docker compose up --build
```

This starts three services:

| Service    | URL                      |
|------------|--------------------------|
| Frontend   | http://localhost:80      |
| Backend    | http://localhost:8080    |
| PostgreSQL | localhost:5432           |

To run in the background (detached):

```bash
docker compose up --build -d
```

### 4. Stop the services

```bash
docker compose down
```

To also remove the database volume (wipes all data):

```bash
docker compose down -v
```

---

## Running Locally (Flutter frontend only)

This is useful for rapid UI development without needing Docker.

### 1. Install Flutter dependencies

```bash
cd frontend
flutter pub get
```

### 2. Run in Chrome

```bash
flutter run -d chrome
```

Or on a specific port:

```bash
flutter run -d chrome --web-port 3000
```

The app will open at `http://localhost:3000` (or the port Flutter selects).

### Hot reload / Hot restart

While `flutter run` is active, use these keyboard shortcuts in the terminal:

| Key | Action       |
|-----|--------------|
| `r` | Hot reload   |
| `R` | Hot restart  |
| `q` | Quit         |

---

## Running the Backend Locally (Dart Frog)

### 1. Install Dart Frog CLI

```bash
dart pub global activate dart_frog_cli
```

### 2. Start the dev server

```bash
cd backend
dart pub get
dart_frog dev
```

The API will be available at `http://localhost:8080`.

---

## macOS — Docker without Docker Desktop

If you use [Colima](https://github.com/abiosoft/colima) instead of Docker Desktop:

```bash
# Install
brew install colima docker docker-compose

# Configure the docker compose plugin
mkdir -p ~/.docker
# Add to ~/.docker/config.json:
# "cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]

# Start the VM
colima start

# Then run the project as normal
docker compose up --build
```

---

## Project Structure

```
Budgetting-App/
├── frontend/           # Flutter web application
│   ├── lib/
│   │   ├── core/       # Theme, router, utilities
│   │   └── features/   # Feature modules (dashboard, auth, etc.)
│   └── Dockerfile
├── backend/            # Dart Frog REST API
│   ├── routes/         # API route handlers
│   ├── lib/            # Models, services, repositories
│   └── Dockerfile
├── docker-compose.yml
├── docker-compose.override.yml  # Local dev overrides
└── .env.example
```

---

## Environment Variables

| Variable            | Description                          | Default              |
|---------------------|--------------------------------------|----------------------|
| `POSTGRES_DB`       | Database name                        | `budgetting`         |
| `POSTGRES_USER`     | Database user                        | `budgetting_user`    |
| `POSTGRES_PASSWORD` | Database password                    | *(must be set)*      |
| `JWT_SECRET`        | Secret key for signing JWT tokens    | *(must be set)*      |
| `PORT`              | Backend server port                  | `8080`               |
| `API_BASE_URL`      | Base URL the frontend calls          | `http://localhost:8080` |
