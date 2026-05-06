# Production Migration Plan

This document tracks the full backend + frontend production migration plan, the work completed so far, and the remaining phases.

## Scope
- Migrate from mock-driven Flutter flows to real backend APIs.
- Harden backend configuration, data, and auth for production readiness.
- Seed Supabase with controlled mock data for staging.
- Prepare frontend for authenticated API usage.

## Phase Overview and Status

### Phase 0 - Production baselines (COMPLETED)
Goal: ensure production-safe configuration, secrets, and CORS behavior.

Completed:
- Configurable CORS for HTTP + Socket.io using `CORS_ORIGINS` and `FRONTEND_URL`.
- Firebase admin credential loading from `FIREBASE_SERVICE_ACCOUNT` with safe fallback.

### Phase 1 - Database readiness (COMPLETED)
Goal: make the DB connection stable and configurable for production.

Completed:
- Added connection pooling and logging controls for Sequelize (`DB_POOL_*`, `SEQUELIZE_LOGGING`).

### Phase 2 - Seed strategy (COMPLETED)
Goal: seed a staging DB with deterministic mock data.

Completed:
- Seed runner added.
- Seed fixtures created for users, posts, chats, messages, notifications, reports.
- ID mapping documented.

### Phase 3 - Backend API readiness (COMPLETED)
Goal: align response shapes and ensure minimal health checks.

Completed:
- Response helper updated to allow metadata.
- Health endpoint added.
- Report controller standardized to the shared response utility.
- Post controller fixed for param names and pagination metadata.

### Phase 4 - Frontend integration (IN PROGRESS)
Goal: shift UI to real API calls with Firebase auth tokens.

Completed:
- ApiClient now accepts a token provider.
- API constants aligned to backend routes.
- Matching and post data sources updated to parse `data` responses.
- Home screen now uses `PostProvider` (API-backed).
- Login and signup now sync Firebase users to the backend via `/user/login`.

Remaining:
- Switch Messages screen from mock service to chat API.
- Switch Notifications screen from mock service to API (requires backend endpoints).
- Switch My Posts screen to `/post/my-posts`.
- Add user profile fetch to `/user/me` and store in app state.

### Phase 5 - Security and observability (NOT STARTED)
Goal: add logging standards, security headers, and runtime monitoring.

Planned:
- Add rate limiting and request size limits.
- Add security headers (helmet) and request IDs.
- Add structured error logging and tracing.

### Phase 6 - Deployment and release (NOT STARTED)
Goal: define hosting, CI/CD, and release flow.

Planned:
- Choose hosting for backend and configure CI/CD.
- Ensure DB migrations run on deploy.
- Build and sign Flutter release artifacts.

### Phase 7 - Verification (NOT STARTED)
Goal: end-to-end validation before production.

Planned:
- Seed staging and validate row counts.
- Smoke test API endpoints with real Firebase tokens.
- Validate all Flutter screens with real data.

## Completed Assets
- Seed data fixtures in `Backend/scripts/seed-data/`.
- Seed runner in `Backend/scripts/seed.js`.
- CORS and Firebase env config in backend.
- Auth sync between Firebase and backend on login/signup.

## Remaining Decisions
- Notification API: build endpoints or keep mock-only for now.
- Migration approach: Sequelize CLI migrations vs controlled sync.
- Flutter environment config: build flavors vs runtime config.

## Immediate Next Steps
1) Decide whether to implement Notification endpoints now.
2) Convert Messages and My Posts screens to API data sources.
3) Add a user profile cache from `/user/me`.

## Notes
- Backend login flow requires a valid Firebase ID token and `{ name, email }` body.
- The middleware now allows `/user/login` even for first-time users.
