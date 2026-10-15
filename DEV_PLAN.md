# UniMate Dev Plan (Pass scope)

Last updated: 2026-10-15. Replaces the 2026-10-09 plan.

**Goal:** finish P9 (complete app plus About page, submitted on OnTrack) and P7 (dark mode, Dynamic Type, orientation) together. P8 was submitted on 2026-10-15.

**Hard deadline:** the P7 lab demo must happen in the **Week 12 lab** (next week). If labs aren't done by Week 12, the task fails. The P9 demo is in Week 14/15.

## Working constraints

- **Rule: finish every Windows phase (0–7) before any Mac session.** The Mac is used only to compile, fix and install, never to write features.

- **Mac time is scarce** (borrowed laptop). Do everything possible on Windows, and use the Mac only to compile, fix and install.
- **Windows** has the .NET 8 SDK and Docker. The backend is built, run and tested fully here. Swift is written here without compiling, so it needs careful, conservative code.
- **Testing device: the user's iPad.** It's installed from the Mac with a free Apple ID.
  - Free provisioning expires after **7 days**, so reinstall within 7 days of each demo (Week 12 lab and Week 14/15).
  - Check the iPad's iOS version. The project currently targets **iOS 26.5**. Phase 0 lowers it to **17.0**, the lowest version that has SwiftData, `@Observable` and `ContentUnavailableView`.
- **The iPad must reach the API**, so the API runs on the Windows laptop on the same Wi-Fi, at `http://<windows-ip>:5080`. Campus Wi-Fi (eduroam) usually blocks device-to-device traffic, so see Phase 8 for the demo plan.

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

---

## Phase 0: Repo safety and project settings (Windows, 30 min)
- [ ] Commit the current uncommitted redesign: *"Move redesign into Xcode project"*.
- [ ] In `project.pbxproj`: `IPHONEOS_DEPLOYMENT_TARGET = 17.0`, add the `UIAppFonts` key, and a local-network usage description (needed so the iPad can reach the LAN API).
- [ ] Add `Info.plist` keys: `NSAppTransportSecurity` → `NSAllowsLocalNetworking`, so HTTP to the LAN API is allowed. If the iPad still refuses the IP address, fall back to `NSAllowsArbitraryLoads` for the demo build.
- [ ] Delete the template `ContentView.swift`.

## Phase 1: P7 foundation (Windows, 1 h)
- [ ] `Theme.swift`: make every `UniColor` adaptive with `UIColor { traits in … }`. Pick dark values for canvas, sunken, raised, hairline, the ink colours, the washes and the accents, and lower the shadow opacity in dark mode.
- [ ] Replace the 4 `.system(size:)` fonts with text styles. Use `@ScaledMetric` for icon frames next to text.
- [ ] Review existing screens for fixed heights. Make sure tall screens scroll, and use `ViewThatFits` for rows that need to stack at large text sizes.
- [ ] All new screens in later phases use `UniColor` and `UniFont` only, so P7 stays consistent.

## Phase 2: Simplify the backend (Windows, 1 h)
- [ ] Delete `UniMate.Application` and `UniMate.Infrastructure`. Move the Npgsql, EF Design and Identity.Core packages into Api, and remove JwtBearer.
- [ ] Trim the entities:
  - `User`: Id, Email, PasswordHash, FirstName, LastName, Role, CreatedAt.
  - `Category`: Id, Name, Icon.
  - `Job`: Id, ClientId, CategoryId, Title, Description, Budget, Suburb, ScheduledAt, Status, AssignedFreelancerId, timestamps.
  - `JobApplication`: Id, JobId, FreelancerId, Message, Status, CreatedAt.
  - `Report`: Id, ReporterId, JobId, Reason, Details, Status, CreatedAt.
- [ ] Delete the unused entities: Language, Skill, FreelancerSkill, FreelancerLanguage, Offer, Review, RefreshToken, PasswordResetCode, ClientProfile, FreelancerProfile.
- [ ] `JobStatus`: Open, Assigned, Completed. `ApplicationStatus`: Pending, Accepted, Rejected. `ReportStatus`: Open, Reviewed, Resolved.
- [ ] `AppDbContext`, with the connection string in **user-secrets**. Seed categories and one admin user with `HasData`.
- [ ] Create the `InitialCreate` migration and apply it to the Docker Postgres.

## Phase 3: API endpoints (Windows, 2.5 h)
Minimal APIs, grouped by feature (`AuthEndpoints.cs`, `JobEndpoints.cs`, `ReportEndpoints.cs`), using DTO records and async EF.

| Method | Route | Purpose | Responses |
|---|---|---|---|
| POST | `/api/auth/register` | Create a Client or Freelancer | 201 / 400 / 409 |
| POST | `/api/auth/login` | Returns a `UserDto` | 200 / 401 |
| GET | `/api/categories` | Categories for the picker | 200 |
| GET | `/api/jobs?status=&categoryId=&clientId=` | Browse jobs / my jobs | 200 |
| GET | `/api/jobs/{id}` | Job detail | 200 / 404 |
| POST | `/api/jobs` | Post a job (validated) | 201 / 400 |
| GET | `/api/jobs/{id}/applications` | Applicants for a job | 200 / 404 |
| POST | `/api/jobs/{id}/applications` | Apply | 201 / 400 / 404 / 409 |
| GET | `/api/applications?freelancerId=` | My Work | 200 |
| POST | `/api/applications/{id}/accept` | Accept: the job becomes Assigned | 204 / 400 / 403 / 404 |
| POST | `/api/jobs/{id}/complete` | Assigned → Completed | 204 / 400 / 403 / 404 |
| POST | `/api/reports` | Report a job | 201 / 400 |
| GET | `/api/reports` | Admin: list reports | 200 |
| PATCH | `/api/reports/{id}` | Admin: change a report's status | 204 / 400 / 404 |

- [ ] Put the status rules in small methods on `Job` (`CanAccept`, `CanComplete`), so they can be tested without HTTP.
- [ ] Turn on Swagger, remove `UseHttpsRedirection`, listen on `http://0.0.0.0:5080`, and add a Windows firewall rule for port 5080.
- [ ] Update `UniMate.Api.http` with an example request for every endpoint.
- [ ] xUnit tests for the status rules and for duplicate applications.
- [ ] Check every endpoint in Swagger. Commit: *"Add minimal API with EF Core and PostgreSQL"*.

## Phase 4: iOS networking and auth (Windows, written without compiling, 1.5 h)
- [ ] `Services/APIClient.swift`: `get` and `send` built on `URLSession` and `Codable`, with the base URL in one place. Maps errors to friendly messages (can't reach the server, validation messages from 400/409).
- [ ] `Models/`: `Job`, `JobApplication`, `Category`, `Report` DTO structs that match the API JSON.
- [ ] `APIAuthService: AuthServicing` replaces `MockAuthService`. Remove forgot password and the reset code from the UI, because they're out of scope.
- [ ] Add a server address setting on the sign-in screen (stored in `@AppStorage`), so the iPad can point at whichever laptop runs the API without rebuilding.

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

## Mac session 1: compile and install (target: 2 h)
- [ ] Pull the repo, open the project, and set the Team to your free Apple ID. Change the bundle ID if Xcode asks.
- [ ] Build and fix compile errors. Paste the errors to Claude in batches.
- [ ] Install on the iPad (trust the developer certificate in Settings → General → VPN & Device Management).
- [ ] Push the fixes.

## Phase 8: Test on the iPad and demo plan (Windows + iPad, 1.5 h)
- [ ] Run the API on Windows, then on the iPad set the server to `http://<windows-ip>:5080`.
- [ ] Run the full flow. Use two accounts on one iPad (sign out and back in), or a second device or the Swagger UI for the "other user".
- [ ] Failure tests: API stopped, empty or invalid input, negative budget, double tap, applying twice.
- [ ] P7 checks: dark mode, the largest accessibility text size (Settings → Accessibility → Display & Text Size → Larger Text), and portrait and landscape on every screen.
- [ ] **Demo network:** check whether the lab Wi-Fi lets the iPad reach the laptop. If it doesn't, use a **phone hotspot** with both the laptop and the iPad on it. That's the simplest option. Cloud hosting is the alternative (an optional extra, not planned).
- [ ] List the bugs and fix them on Windows.

## Mac session 2: final build (target: 1 h, within 7 days of the Week 12 lab)
- [ ] Pull, build and reinstall on the iPad. Smoke test.
- [ ] Repeat a quick reinstall before the Week 14/15 P9 demo, because free provisioning expires after 7 days.

## Phase 9: Submit
- [ ] README: run Postgres (`docker compose up`), set user-secrets, `dotnet ef database update`, `dotnet run`, then build the app and set the server address.
- [ ] Commit, push, and submit the P9 repo link on OnTrack. In the comment, ask whether the self-built ASP.NET API meets the web service requirement, and mention that offers and matching were cut.
- [ ] Make sure the P6 on OnTrack is the revised ASP.NET version.
- [ ] **Week 12 lab:** P7 demo on the iPad (toggle dark mode, change text size, rotate).
- [ ] **Week 14/15:** P9 demo. Be ready to explain: SwiftUI view → `APIClient` → endpoint → EF Core → Postgres; SwiftData as the device cache; the status rules and tests; what was cut and why.

## If time runs short
Cut in this order: admin reports → the SwiftData offline cache (keep the remembered sign-in, so persistence still exists) → pull-to-refresh.
Never cut: P7, the core flow, error states, About.

## Dropped (no work)
MapKit/Core Location, notifications, the matching algorithm and score UI, Swift Charts, reviews/ratings, direct offers, JWT and refresh tokens, forgot password, C1/C2/HD1.
