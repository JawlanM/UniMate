# UniMate API Design

List of planned API endpoints for the backend. Only `/api/health` is built
right now. Everything else is planned. Mark a row as Done only after it is
actually implemented in code.

## Base

Base URL (dev): http://localhost:5034
Format: JSON
Auth: not implemented yet. Plan is JWT bearer tokens from `/api/auth/login`,
sent in the Authorization header.
Status codes used: 200, 201, 204, 400, 401, 403, 404
Requests and responses use DTOs, not EF entities directly.

## Endpoints

### Health

| Method | Route         | Purpose        | Auth | Status |
|--------|---------------|----------------|------|--------|
| GET    | `/api/health` | Liveness check | No   | Done   |

### Auth

| Method | Route                | Purpose                              | Auth | Status  |
|--------|----------------------|---------------------------------------|------|---------|
| POST   | `/api/auth/register` | Create account (Employer or Freelancer) | No | Planned |
| POST   | `/api/auth/login`    | Log in, returns bearer token          | No   | Planned |

### Users

| Method | Route           | Purpose                            | Auth | Status  |
|--------|-----------------|--------------------------------------|------|---------|
| GET    | `/api/users/me` | Get current user's base profile      | Yes  | Planned |
| PATCH  | `/api/users/me` | Update current user's base profile   | Yes  | Planned |

### Employers

| Method | Route                 | Purpose                | Auth | Status  |
|--------|-----------------------|--------------------------|------|---------|
| GET    | `/api/employers/{id}` | Get an employer profile | Yes  | Planned |
| POST   | `/api/employers`      | Create employer profile | Yes  | Planned |
| PATCH  | `/api/employers/{id}` | Update employer profile | Yes  | Planned |

### Freelancers

| Method | Route                   | Purpose                                              | Auth | Status  |
|--------|-------------------------|--------------------------------------------------------|------|---------|
| GET    | `/api/freelancers`      | Search freelancers by category, location, rating       | Yes  | Planned |
| GET    | `/api/freelancers/{id}` | Get a freelancer profile                               | Yes  | Planned |
| POST   | `/api/freelancers`      | Create freelancer profile                              | Yes  | Planned |
| PATCH  | `/api/freelancers/{id}` | Update freelancer profile (skills, availability)       | Yes  | Planned |

### Categories

| Method | Route             | Purpose                            | Auth | Status  |
|--------|-------------------|---------------------------------------|------|---------|
| GET    | `/api/categories` | List categories with nested skills    | No   | Planned |

### Jobs

| Method | Route            | Purpose                                        | Auth | Status  |
|--------|------------------|---------------------------------------------------|------|---------|
| GET    | `/api/jobs`      | Search jobs by category, location, status         | Yes  | Planned |
| GET    | `/api/jobs/{id}` | Get a single job                                   | Yes  | Planned |
| POST   | `/api/jobs`      | Employer creates a job                             | Yes  | Planned |
| PATCH  | `/api/jobs/{id}` | Employer updates a job                             | Yes  | Planned |
| DELETE | `/api/jobs/{id}` | Employer cancels a job                             | Yes  | Planned |

### Proposals

| Method | Route                         | Purpose                            | Auth | Status  |
|--------|-------------------------------|---------------------------------------|------|---------|
| GET    | `/api/jobs/{jobId}/proposals` | Employer views proposals for their job | Yes | Planned |
| POST   | `/api/jobs/{jobId}/proposals` | Freelancer submits a proposal          | Yes | Planned |
| GET    | `/api/proposals/{id}`         | Get a single proposal                  | Yes | Planned |
| PATCH  | `/api/proposals/{id}`         | Freelancer withdraws or edits proposal | Yes | Planned |

### Offers

| Method | Route              | Purpose                                | Auth | Status  |
|--------|--------------------|-------------------------------------------|------|---------|
| POST   | `/api/offers`      | Employer sends an offer for a proposal    | Yes  | Planned |
| GET    | `/api/offers/{id}` | Get a single offer                        | Yes  | Planned |
| PATCH  | `/api/offers/{id}` | Freelancer accepts or declines an offer   | Yes  | Planned |

### Matches

This is the weighted matching algorithm from the P6 proposal (category,
distance, availability, language, rating, experience).

| Method | Route                       | Purpose                                | Auth | Status  |
|--------|-----------------------------|--------------------------------------------|------|---------|
| GET    | `/api/jobs/{jobId}/matches` | Ranked freelancer recommendations for a job | Yes | Planned |

### Reports

| Method | Route               | Purpose                                     | Auth  | Status  |
|--------|---------------------|--------------------------------------------------|-------|---------|
| POST   | `/api/reports`      | Submit a report against a user or job            | Yes   | Planned |
| GET    | `/api/reports`      | Admin lists reports                              | Admin | Planned |
| PATCH  | `/api/reports/{id}` | Admin updates report status or suspends a user   | Admin | Planned |

## Examples

These show the planned request and response shape. None of these routes are
built yet except health.

### POST /api/auth/register

Request:
```json
{
  "email": "alex@student.monash.edu",
  "password": "min-8-characters",
  "firstName": "Alex",
  "lastName": "Tan",
  "role": "Freelancer"
}
```

Response, 201 Created:
```json
{
  "id": "3f1b2c40-1234-4a2b-9f00-abcdef123456",
  "email": "alex@student.monash.edu",
  "role": "Freelancer",
  "createdAt": "2026-09-17T09:00:00Z"
}
```

### POST /api/jobs

Request:
```json
{
  "title": "Help moving a couch",
  "categoryId": "moving",
  "description": "Need one person for about an hour, ground floor only.",
  "date": "2026-09-20",
  "generalLocation": "Clayton, near campus",
  "budget": 30
}
```

Response, 201 Created:
```json
{
  "id": "a9d4e210-1234-4a2b-9f00-abcdef123456",
  "title": "Help moving a couch",
  "categoryId": "moving",
  "employerId": "8b2f0000-1234-4a2b-9f00-abcdef123456",
  "status": "Open",
  "createdAt": "2026-09-17T09:05:00Z"
}
```

### GET /api/jobs/{jobId}/matches

Response, 200 OK:
```json
{
  "jobId": "a9d4e210-1234-4a2b-9f00-abcdef123456",
  "matches": [
    {
      "freelancerId": "c11a0000-1234-4a2b-9f00-abcdef123456",
      "name": "Priya S.",
      "score": 0.87,
      "breakdown": {
        "categoryMatch": 0.3,
        "distance": 0.2,
        "availability": 0.15,
        "rating": 0.12,
        "experience": 0.1
      }
    },
    {
      "freelancerId": "d92b0000-1234-4a2b-9f00-abcdef123456",
      "name": "Wei L.",
      "score": 0.74,
      "breakdown": {
        "categoryMatch": 0.3,
        "distance": 0.1,
        "availability": 0.15,
        "rating": 0.09,
        "experience": 0.1
      }
    }
  ]
}
```

### PATCH /api/offers/{id}

Request:
```json
{
  "status": "Accepted"
}
```

Response, 200 OK:
```json
{
  "id": "f0a10000-1234-4a2b-9f00-abcdef123456",
  "status": "Accepted",
  "respondedAt": "2026-09-17T10:00:00Z"
}
```

## Conventions

Plural nouns for collections, for example `/api/jobs`, `/api/users`.
Nested routes only when a resource belongs to a parent, for example
`/api/jobs/{jobId}/proposals`.
IDs are GUIDs, matching EF Core default keys.
Timestamps are ISO 8601 UTC.
