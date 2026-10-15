# UniMate API Design

Everything below is implemented. Swagger shows the same list at `/swagger`.

## Base

- Local: `http://localhost:5034`. Live: the Render URL (Phase 3b).
- JSON in and out, camelCase. Enums are sent as text (`"Open"`, `"Client"`).
- Requests and responses use DTOs (`UniMate.Api/Dtos`), never EF entities.
- Every error has the same body: `{ "message": "..." }`.
- **No tokens.** Login returns the user. The app keeps the user's `id` and sends it with each action (`clientId`, `freelancerId` or `userId`). The API checks that the user is allowed. This is a known limitation: the next step would be JWT, where the id comes from a signed token instead of the body.

| Code | Meaning |
|---|---|
| 200 | Here's the data |
| 201 | Created (the new item is in the body) |
| 204 | Done, nothing to return |
| 400 | Invalid input, or the status rules don't allow it |
| 401 | Wrong email or password |
| 403 | This user isn't allowed |
| 404 | Not found |
| 409 | Already exists (email taken, already applied) |

## Endpoints

| Method | Route | Purpose | Responses |
|---|---|---|---|
| GET | `/api/health` | API and database check | 200 |
| POST | `/api/auth/register` | Create a Client or Freelancer | 201 / 400 / 409 |
| POST | `/api/auth/login` | Returns a `UserDto` | 200 / 401 |
| GET | `/api/categories` | Categories for the picker | 200 |
| GET | `/api/jobs?status=&categoryId=&clientId=` | Browse jobs / my jobs (all filters optional) | 200 |
| GET | `/api/jobs/{id}` | Job detail | 200 / 404 |
| POST | `/api/jobs` | Post a job (clients only) | 201 / 400 / 403 |
| POST | `/api/jobs/{id}/complete` | Assigned → Completed (the job's client) | 204 / 400 / 403 / 404 |
| POST | `/api/jobs/{id}/cancel` | Open → Cancelled (the job's client) | 204 / 400 / 403 / 404 |
| GET | `/api/jobs/{id}/applications` | Applicants for a job | 200 / 404 |
| POST | `/api/jobs/{id}/applications` | Apply (freelancers only, once per job) | 201 / 400 / 403 / 404 / 409 |
| GET | `/api/applications?freelancerId=` | A freelancer's applications (My Work) | 200 |
| POST | `/api/applications/{id}/accept` | Accept: job becomes Assigned, other pending applications Rejected | 204 / 400 / 403 / 404 |
| POST | `/api/applications/{id}/withdraw` | Pending → Withdrawn (the freelancer who applied) | 204 / 400 / 403 / 404 |
| POST | `/api/reports` | Report a job | 201 / 400 / 404 |
| GET | `/api/reports?userId=` | All reports (admin) | 200 / 403 |
| PATCH | `/api/reports/{id}` | Set status to UnderReview / Resolved / Dismissed (admin) | 204 / 400 / 403 / 404 |

Action bodies (accept, withdraw, complete, cancel): `{ "userId": "..." }`.
Example requests for every route are in `UniMate.Api/UniMate.Api.http`.

## Status rules

These live in `Job` and `JobApplication` (Domain) and are unit-tested in `UniMate.Tests/JobRulesTests.cs`.

```
Job:         Open → Assigned → Completed
             Open → Cancelled
Application: Pending → Accepted | Rejected | Withdrawn
Report:      Open → UnderReview → Resolved | Dismissed
```

- Apply only to an Open job, once per freelancer. Withdrawing is final, so you can't reapply. The unique (JobId, FreelancerId) index backs this up.
- Accepting one application rejects the other pending ones in the same save.
- Cancelling a job rejects its pending applications.

## Data

PostgreSQL through EF Core (`UniMate.Api/Data/AppDbContext.cs`). Tables: Users, Categories (6 seeded), Jobs, JobApplications, Reports. Migrations apply automatically when the API starts. The admin user (`admin@unimate.app`) is created at startup from `SeedAdmin:Password`.

## Configuration

| Key | Local | Render |
|---|---|---|
| `ConnectionStrings:Default` | user-secrets | env var `ConnectionStrings__Default` |
| `SeedAdmin:Password` | user-secrets | env var `SeedAdmin__Password` |

Never put either value in `appsettings.json` or git.
