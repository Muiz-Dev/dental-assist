# DentAssist

DentAssist is an AI-powered dental education, symptom guidance, and clinic discovery platform.

## Architecture & Monorepo Structure

```
dentassist/
├── frontend/        # Flutter client application
├── backend/         # Java 21 / Spring Boot REST API
├── docs/            # Architecture & design specifications
├── scripts/         # Utility scripts
├── docker-compose.yml
├── .env.example
└── README.md
```

## Prerequisites

- **Java 21+**
- **Flutter 3.41+**
- **Docker & Docker Compose**

## Local Infrastructure Setup

Start the local PostgreSQL and Redis services:

```bash
docker compose up -d
```

To stop local services:

```bash
docker compose down
```

## Backend Setup (Spring Boot)

Navigate to the `backend` directory and run tests / start the service:

```bash
cd backend
./mvnw clean test
./mvnw spring-boot:run
```

The API will run locally at `http://localhost:8080`.

### Health Endpoints
- `GET http://localhost:8080/api/v1/health`
- `GET http://localhost:8080/api/v1/health/readiness`

## Frontend Setup (Flutter)

Navigate to the `frontend` directory:

```bash
cd frontend
flutter pub get
flutter run -d chrome # or linux/macos/windows/emulator
```

## Environment Configuration

Copy `.env.example` to `.env` (ignored by Git) and configure local secrets as needed.

```bash
cp .env.example .env
```
