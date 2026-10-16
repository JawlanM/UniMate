# UniMate Dev Plan (Pass scope)

Last updated: 2026-10-17. Replaces the 2026-10-09 plan.

**Goal:** finish P9: the complete app plus an About page, submitted on OnTrack, then a live demo and discussion in Week 14/15.

**Done:**
- P8 was submitted on 2026-10-15.
- P7 was submitted on 2026-10-17 with Simulator screenshots (light/dark, Dynamic Type, Large Content Viewer, portrait/landscape). No live demo was needed.

**Next deadline:** the P9 demo in Week 14/15.

## Working constraints

- **Rule: finish every Windows phase (0–7) before any Mac session.** The Mac is used only to compile, fix and install, never to write features.

- **Mac time is scarce** (borrowed laptop). Do everything possible on Windows, and use the Mac only to compile, fix and install.
- **Windows** has the .NET 8 SDK and Docker. The backend is built, run and tested fully here. Swift is written here without compiling, so it needs careful, conservative code.
- **Testing device: the user's iPad.** It's installed from the Mac with a free Apple ID.
  - Free provisioning expires after **7 days**, so install within 7 days of the Week 14/15 P9 demo.
  - The project targets **iOS 17.0**, the lowest version that has SwiftData, `@Observable` and `ContentUnavailableView`.
- **The API is hosted on Render, and the database on Neon** (Phase 3b). The iPad reaches it over HTTPS from any network, so the demo doesn't depend on the laptop, the lab Wi-Fi or a firewall. Locally the API still runs on `localhost` with the Docker Postgres for development.

## Decisions (2026-10-15)

1. **Auth goes through the API** (register and login with hashed passwords). There's no JWT. The app sends `userId` with requests. This is a known limitation to mention in the demo.
2. **Direct offers are cut.** The "client chooses a freelancer" step happens through applications. Note this as a change from P6.
3. **Mock recommendations are removed** (`MockData`, `RecommendationsView`, the match panels on Home), because the matching feature was dropped.
4. **Responsibilities:** the API holds shared data (users, jobs, applications, reports). SwiftData holds this device's data (the remembered sign-in, and cached jobs for offline viewing).
5. **The backend is one API project plus Domain.** The empty Application and Infrastructure projects are deleted.

## Job flow and status rules

```
Client posts job (Open)
  → Freelancers apply (application Pending)
  → Client accepts one (job Assigned; that application Accepted, others Rejected)
  → Client marks complete (job Completed)
```

Rules, enforced in the API and covered by tests:
- Apply only to an **Open** job, once per freelancer, and never to your own job.
- Accept only on an **Open** job, and only by the job's client.
- Complete only an **Assigned** job, and only by the job's client.
- Cancel only an **Open** job, and only by the job's client (its pending applications become Rejected).
- Withdraw only a **Pending** application, and only by the freelancer who sent it. Withdrawing is final: the unique (JobId, FreelancerId) index means you can't reapply.
- Reports: Open → UnderReview → Resolved or Dismissed (admin only).

---

## Phase 0: Repo safety and project settings (Windows): DONE 2026-10-15
- [x] Committed the redesign (`6072f6f`).
- [x] The target is now iOS-only (iPhone and iPad), with `IPHONEOS_DEPLOYMENT_TARGET = 17.0`. Removed the macOS, visionOS and Catalyst settings and the app sandbox. The display name is "UniMate".
- [x] `ios/PortfolioApp/Info.plist` is merged with the generated plist (`INFOPLIST_FILE`). It sits outside the synced folder, so it isn't copied as a resource. It contains:
  - `UIAppFonts`, for the 3 Bricolage files,
  - `NSAllowsArbitraryLoads`, because the API is plain HTTP on a LAN IP (chosen so we don't burn Mac time testing `NSAllowsLocalNetworking`),
  - `NSLocalNetworkUsageDescription`.
- [x] Deleted the template `ContentView.swift`.

## Phase 1: P7 foundation (Windows): DONE 2026-10-15, P7 SUBMITTED 2026-10-17
- [x] `Theme.swift`: every `UniColor` is adaptive through `Color.adaptive(light:dark:)` (`UIColor { traits in … }`). New tokens:
  - `onApricot`: always dark, because apricot is light in both modes,
  - `bar` and `onBar`: the tab bar stays dark,
  - `onInk`: flips with the mode.

  `LiftShadow` uses a stronger black shadow in Dark Mode.
- [x] Avatar initials are fixed white, since avatar colours are dark in both modes. The brand button, the tab bar plus button and the selected role icon use `onApricot`.
- [x] Tab bar: `.dynamicTypeSize(...xxxLarge)` and `.accessibilityShowsLargeContentViewer`, matching the system tab bar.
- [x] Orientation: every remaining screen already scrolls. `readableWidth()` (max 640, centred) is applied to Welcome, Sign in, Register and Profile.
- [x] The fixed `.system(size:)` fonts that remain are only in screens deleted in Phase 4/7 (score ring, stars, forgot password). The avatar initials keep a fixed size on purpose: they fit the circle and are hidden from VoiceOver.
- [x] Verified in the Xcode Simulator on 2026-10-17 and submitted as screenshots: Light/Dark, the largest accessibility text size, the Large Content Viewer on the tab bar, and rotation.
- Rule for later phases: new screens use only `UniColor`, `UniFont` and `readableWidth()`, so P7 stays consistent.

## Phase 2: Simplify the backend (Windows): DONE 2026-10-15
- [x] Deleted `UniMate.Application` and `UniMate.Infrastructure`. The solution is now Api + Domain + Tests. Npgsql and Identity.Core moved into Api, and JwtBearer was removed.
- [x] Trimmed the entities to `User`, `Category` (int Id, Name, IconName), `Job`, `JobApplication` and `Report` (on a job). Deleted the profile, skill, language, offer, review and token entities, plus `OfferStatus` and `WeekDays`.
- [x] **Kept the full status enums (user decision):**
  - `JobStatus`: Open/Assigned/Completed/Cancelled
  - `ApplicationStatus`: Pending/Accepted/Rejected/Withdrawn
  - `ReportStatus`: Open/UnderReview/Resolved/Dismissed

  All are stored as strings.
- [x] `Api/Data/AppDbContext.cs`:
  - a unique index on email, and a unique index on (JobId, FreelancerId),
  - Restrict deletes on every link to User,
  - 6 categories seeded with `HasData`.
- [x] The connection string is in user-secrets (`ConnectionStrings:Default`). The `InitialCreate` migration is applied to the Docker Postgres. `/api/health` returns `database: true`.
- Admin user: moved to Phase 3. It's created at startup together with auth, because `HasData` can't hash a password deterministically.
- Known warning: the EF Core 8.0.11/8.0.31 version conflict in Tests. Fixed in Phase 3 by removing Tests' reference to Api, since the tests only need Domain.

## Phase 3: API endpoints (Windows): DONE 2026-10-16
Minimal APIs, grouped by feature (`AuthEndpoints.cs`, `JobEndpoints.cs`, `ApplicationEndpoints.cs`, `ReportEndpoints.cs`), using DTO records (`Dtos/`) and async EF. Every error is `{ "message": "..." }`. Enums are sent as text.

| Method | Route | Purpose | Responses |
|---|---|---|---|
| POST | `/api/auth/register` | Create a Client or Freelancer | 201 / 400 / 409 |
| POST | `/api/auth/login` | Returns a `UserDto` | 200 / 401 |
| GET | `/api/categories` | Categories for the picker | 200 |
| GET | `/api/jobs?status=&categoryId=&clientId=` | Browse jobs / my jobs | 200 |
| GET | `/api/jobs/{id}` | Job detail | 200 / 404 |
| POST | `/api/jobs` | Post a job (validated, clients only) | 201 / 400 / 403 |
| GET | `/api/jobs/{id}/applications` | Applicants for a job | 200 / 404 |
| POST | `/api/jobs/{id}/applications` | Apply (freelancers only) | 201 / 400 / 403 / 404 / 409 |
| GET | `/api/applications?freelancerId=` | My Work | 200 |
| POST | `/api/applications/{id}/accept` | Accept: the job becomes Assigned | 204 / 400 / 403 / 404 |
| POST | `/api/jobs/{id}/complete` | Assigned → Completed | 204 / 400 / 403 / 404 |
| POST | `/api/jobs/{id}/cancel` | Open → Cancelled (client only) | 204 / 400 / 403 / 404 |
| POST | `/api/applications/{id}/withdraw` | Pending → Withdrawn (freelancer only) | 204 / 400 / 403 / 404 |
| POST | `/api/reports` | Report a job | 201 / 400 / 404 |
| GET | `/api/reports?userId=` | Admin: list reports | 200 / 403 |
| PATCH | `/api/reports/{id}` | Admin: set the status (UnderReview / Resolved / Dismissed) | 204 / 400 / 403 / 404 |

Action endpoints (accept, complete, cancel, withdraw) take `{ "userId": "..." }` in the body.

- [x] Put the status rules in small methods on `Job` and `JobApplication` (`CanApply`, `CanAccept`, `CanComplete`, `CanCancel`, `CanWithdraw`, plus `Accept`/`Complete`/`Cancel`/`Withdraw`), so they can be tested without HTTP.
- [x] Create the admin user (`admin@unimate.app`) at startup if none exists, with the password from config (`SeedAdmin:Password`: user-secrets locally, an env var on Render).
- [x] Apply migrations at startup (`MigrateAsync`), so a new database (Neon) is set up on the first run.
- [x] Swagger on in every environment, so the deployed API can be shown.
- [x] Update `UniMate.Api.http` with an example request for every endpoint.
- [x] xUnit tests for the status rules and for duplicate applications (11 passing).
- [x] Every endpoint checked (50 requests against a throwaway database, all with the expected status). `API_DESIGN.md` rewritten to match.

## Phase 3b: Deploy (Windows + browser): DONE 2026-10-17
Render runs the API from a Dockerfile; Neon hosts PostgreSQL. Both are free with no credit card. Neon's free database doesn't expire, unlike Render's.

- [x] `backend/Dockerfile` (SDK image builds with `dotnet publish`, then the small `aspnet:8.0` image runs it on port 8080) and `backend/.dockerignore` (`**/bin/`, `**/obj/`). Tested locally: the container migrates an empty database, creates the admin once, and serves `/api/health` and `/swagger` in Production.
- [x] Neon: create a project, then copy the connection details into Npgsql format: `Host=...;Database=...;Username=...;Password=...;SSL Mode=Require`. Neon shows a `postgresql://` URL, which Npgsql doesn't accept.
- [x] Render can't reach the Monash GitLab server, so the repo is also on GitHub: `github.com/JawlanM/sideGigs`, remote `github`, public by the user's choice. Monash GitLab stays the submission repo. Push to both remotes after every change.
- [x] Neon settings: Sydney region, Postgres 16, connection pooling off.
- [x] Render: New → Web Service → connect the GitHub repo, root directory `backend`, runtime Docker, Singapore region, free instance, health check path `/api/health`.
- [x] Render env vars: `ConnectionStrings__Default` (the Neon string), `SeedAdmin__Password` and `PORT=8080`. The double underscore maps to the `:` in config keys. Never commit these.
- [x] Live at **`https://unimate-dkrj.onrender.com`**. `/api/health` returns 200, and `/api/categories` returns the 6 seeded categories, so migrations ran on Neon.
- [x] Swagger UI said "does not specify a valid version field": `Microsoft.AspNetCore.OpenApi` 8.0.31 pulls in `Microsoft.OpenApi` 1.6.30, which writes `openapi: 3.0.4`, and the UI bundled with Swashbuckle 6.6.2 only accepts 3.0.0–3.0.3. Fixed by upgrading to Swashbuckle 7.3.2.
- [x] `/swagger` loads after the redeploy, and the admin login returns 200.
- [ ] Note: the free service sleeps after ~15 min idle, and the first request after that takes about a minute. Open the health URL before every demo.
- [ ] Fallback if Render is down on a demo day: run the API on the laptop with `--urls http://0.0.0.0:5080`, open port 5080 in the firewall, and put the laptop and iPad on a phone hotspot.

## Phase 4: iOS networking and auth (Windows): DONE 2026-10-17 (not compiled yet)
- [x] `Services/APIClient.swift`: `get` and `send` built on `URLSession` and `Codable`, with the base URL in one place. Maps errors to friendly messages (can't reach the server, validation messages from 400/409).
- [x] `Models/`: `Job`, `JobApplication`, `Category`, `Report` DTO structs that match the API JSON.
- [x] `APIAuthService: AuthServicing` replaces `MockAuthService`. Remove forgot password and the reset code from the UI, because they're out of scope.
- [x] The base URL is one constant in `APIClient`: the Render HTTPS URL. There's no server address setting, because the API is hosted.
- [x] `Info.plist`: remove `NSAllowsArbitraryLoads` and `NSLocalNetworkUsageDescription`, because the hosted API is HTTPS.
- Notes:
  - .NET dates have 7 decimal places, so `APIClient` strips the fraction before parsing them as ISO 8601.
  - `MockAuthService` is kept for `#Preview`s only.
  - `isVerified` is removed from `AppUser`, because the API doesn't send it.

## Phase 5: Core flow screens (Windows, written without compiling, 3 h)
Role-based tabs in `MainTabView`:

| | Client | Freelancer | Admin |
|---|---|---|---|
| Tab 1 | My Jobs | Browse Jobs (category filter) | Reports |
| Tab 2 | Post Job (+) | My Work | — |
| Tab 3 | Profile | Profile | Profile |

- [ ] `Features/Jobs/`: `JobListView` (shared by My Jobs and Browse), `JobDetailView` (role-aware actions), `PostJobView` (validated form), `ApplySheet`, `ApplicantRow`.
- [ ] `Features/Work/MyWorkView`.
- [ ] `Features/Reports/ReportSheet` and `Features/Admin/ReportsListView`.
- [ ] Every list has a loading state (`ProgressView`), an empty state (`ContentUnavailableView`) and an error state with Retry, plus `.refreshable`.
- [ ] Every form has inline validation, the submit button disabled while sending, and an `ErrorBanner` on failure.
- [ ] Use the iPad's width: `NavigationSplitView` is **not** needed. Just cap the content width so landscape doesn't stretch forms edge to edge.

## Phase 6: SwiftData (Windows, written without compiling, 45 min)
- [ ] `@Model CachedJob`: Browse and My Jobs save what they load. If the API fails, they show the cache with an "Offline, showing saved jobs" banner.
- [ ] Remember the signed-in user (a `@Model SavedSession` or `@AppStorage` with the user JSON), so the app reopens signed in. Sign out clears it.
- [ ] Add `.modelContainer(for:)` in `UniMateApp`.

## Phase 7: Remove the fake parts and add About (Windows, 45 min)
- [ ] Delete `MockData.swift`, `RecommendationsView.swift`, `FreelancerProfileView.swift`, and the components only they use (orbit, score ring, praise, factor rows). Delete `PlaceholderScreen` once nothing uses it.
- [ ] Rewrite Home around real data, or drop Home and make each role's first tab the landing screen. That's simpler, and is the plan.
- [ ] Profile: remove the four rows that lead nowhere, and keep identity, About and Sign out.
- [ ] **About page:**
  - what UniMate does,
  - Maihemuti Jiewulan, student ID 34035176, FIT3178,
  - acknowledgements: Bricolage Grotesque (SIL Open Font License), SF Symbols, ASP.NET Core, Entity Framework Core, Npgsql, PostgreSQL, Swashbuckle, and a generative AI acknowledgement.
- [ ] Commit.

## Mac session 1: first compile: DONE 2026-10-17
- [x] The pre-Phase-4 app builds in Xcode. The only error was an ambiguous `cos`/`sin` call in `MatchOrbit` (`bb6737f`).
- [x] P7 screenshots taken in the Simulator.
- Not installed on the iPad yet. The install waits for Mac session 2, because free provisioning lasts 7 days.
- Before the next Mac commit, `git pull` on the Mac, or discard its local copy of the cos fix.

## Mac session 2: compile the full app (target: 2 h, after Phase 7)
- [ ] Pull the repo, open the project, and set the Team to your free Apple ID. Change the bundle ID if Xcode asks.
- [ ] Build and fix compile errors from Phases 4–7. Paste the errors to Claude in batches.
- [ ] Install on the iPad (trust the developer certificate in Settings → General → VPN & Device Management).
- [ ] Push the fixes to both remotes.

## Phase 8: Test on the iPad and demo plan (Windows + iPad, 1.5 h)
- [ ] Wake the Render API (open `/api/health`), then run the full flow. Use two accounts on one iPad (sign out and back in), or a second device or the Swagger UI for the "other user".
- [ ] Failure tests: Airplane Mode (offline), empty or invalid input, negative budget, double tap, applying twice.
- [ ] Quick check of the new screens: dark mode, large text and landscape. They should be consistent with P7 if they only use `UniColor`, `UniFont` and `readableWidth()`.
- [ ] List the bugs and fix them on Windows.

## Mac session 3: final build (target: 1 h, within 7 days of the Week 14/15 P9 demo)
- [ ] Pull, build and reinstall on the iPad. Smoke test.
- [ ] If Mac sessions 2 and 3 can be combined within the 7-day window, do them in one visit.

## Phase 9: Submit
- [ ] README: the live API URL. To run locally: start Postgres (`docker compose up`), set user-secrets, `dotnet run` (migrations apply on start). Deploy: Render + Neon env vars.
- [ ] Commit, push, and submit the P9 repo link on OnTrack. In the comment, ask whether the self-built ASP.NET API meets the web service requirement, and mention that offers and matching were cut.
- [ ] Make sure the P6 on OnTrack is the revised ASP.NET version.
- [ ] **Week 14/15:** P9 demo. Be ready to explain: SwiftUI view → `APIClient` → endpoint (Render) → EF Core → Postgres (Neon); SwiftData as the device cache; the status rules and tests; what was cut and why.

## If time runs short
Cut in this order: admin reports → the SwiftData offline cache (keep the remembered sign-in, so persistence still exists) → pull-to-refresh.
Never cut: the core flow, error states, About, or the P7 rules in new screens.

## Dropped (no work)
MapKit/Core Location, notifications, the matching algorithm and score UI, Swift Charts, reviews/ratings, direct offers, JWT and refresh tokens, forgot password, C1/C2/HD1.
