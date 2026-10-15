using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;
using UniMate.Api.Dtos;
using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Endpoints;

public static class ReportEndpoints
{
    public static void MapReportEndpoints(this IEndpointRouteBuilder app)
    {
        var reports = app.MapGroup("/api/reports").WithTags("Reports");

        reports.MapPost("/", CreateReport);
        reports.MapGet("/", GetReports);
        reports.MapPatch("/{id:guid}", UpdateReport);
    }

    static Task<bool> IsAdmin(AppDbContext db, Guid userId) =>
        db.Users.AnyAsync(u => u.Id == userId && u.Role == UserRole.Admin);

    // Any signed-in user can report a job.
    static async Task<IResult> CreateReport(CreateReportRequest request, AppDbContext db)
    {
        if (!Enum.IsDefined(request.Reason)) return ApiError.BadRequest("Pick a reason.");
        if (request.Details.Length > 1000) return ApiError.BadRequest("Details must be 1000 characters or fewer.");
        if (!await db.Users.AnyAsync(u => u.Id == request.ReporterId)) return ApiError.BadRequest("Unknown user.");
        if (!await db.Jobs.AnyAsync(j => j.Id == request.JobId)) return ApiError.NotFound("Job not found.");

        var report = new Report
        {
            Id = Guid.NewGuid(),
            ReporterId = request.ReporterId,
            JobId = request.JobId,
            Reason = request.Reason,
            Details = request.Details.Trim(),
            CreatedAt = DateTimeOffset.UtcNow
        };

        db.Reports.Add(report);
        await db.SaveChangesAsync();

        var created = await db.Reports.Include(r => r.Reporter).Include(r => r.Job).FirstAsync(r => r.Id == report.Id);
        return Results.Created($"/api/reports/{report.Id}", created.ToDto());
    }

    // Admin only: /api/reports?userId=<admin id>
    static async Task<IResult> GetReports(Guid userId, AppDbContext db)
    {
        if (!await IsAdmin(db, userId)) return ApiError.Forbidden("Only admins can see reports.");

        var reports = await db.Reports
            .Include(r => r.Reporter)
            .Include(r => r.Job)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
        return Results.Ok(reports.Select(r => r.ToDto()));
    }

    // Admin only: move a report to UnderReview, Resolved or Dismissed.
    static async Task<IResult> UpdateReport(Guid id, UpdateReportRequest request, AppDbContext db)
    {
        if (!await IsAdmin(db, request.UserId)) return ApiError.Forbidden("Only admins can update reports.");
        if (!Enum.IsDefined(request.Status) || request.Status == ReportStatus.Open)
            return ApiError.BadRequest("Status must be UnderReview, Resolved or Dismissed.");

        var report = await db.Reports.FindAsync(id);
        if (report is null) return ApiError.NotFound("Report not found.");

        report.Status = request.Status;
        await db.SaveChangesAsync();
        return Results.NoContent();
    }
}
