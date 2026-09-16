# UniMate API Design

Living document — add an entry here when a real endpoint is built, not before.
Keep it in sync with `Program.cs` (or the relevant controller once the
solution splits into Application/Domain/Infrastructure).

## Base

- Base URL (dev): `http://localhost:5034`
- Format: JSON
- Auth: TBD (not implemented yet)

## Endpoints

| Method | Route         | Purpose               | Auth required | Status |
|--------|---------------|------------------------|----------------|--------|
| GET    | `/api/health` | Liveness check         | No             | Done   |

## Conventions (decide as they come up, don't pre-guess)

- Status codes: 200 OK, 201 Created, 204 No Content, 400 Bad Request,
  401 Unauthorized, 403 Forbidden, 404 Not Found (per AGENTS.md).
- Use DTOs, not raw EF entities, once the domain model exists.
- Naming: plural nouns for resource collections (`/api/jobs`, `/api/users`).

## Next entries expected (per AGENTS.md's planned resources)

Not built yet — listed only so this doc's next edits are predictable:
`/api/auth`, `/api/users`, `/api/employers`, `/api/freelancers`,
`/api/categories`, `/api/jobs`, `/api/proposals`, `/api/offers`,
`/api/matches`, `/api/reports`.
