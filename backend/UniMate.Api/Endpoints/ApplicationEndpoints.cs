using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;
using UniMate.Api.Dtos;
using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Endpoints;

public static class ApplicationEndpoints
{
    public static void MapApplicationEndpoints(this IEndpointRouteBuilder app)
    {
        // Applications for one job live under the job...
        app.MapGet("/api/jobs/{jobId:guid}/applications", GetApplicationsForJob).WithTags("Applications");
        app.MapPost("/api/jobs/{jobId:guid}/applications", Apply).WithTags("Applications");

        // ...and actions on one application live under /api/applications.
        var applications = app.MapGroup("/api/applications").WithTags("Applications");

        applications.MapGet("/", GetApplicationsForFreelancer);
        applications.MapPost("/{id:guid}/accept", Accept);
        applications.MapPost("/{id:guid}/withdraw", Withdraw);
    }

     // Applications with everything ApplicationDto needs.
    static IQueryable<JobApplication> ApplicationsWithDetails(AppDbContext db) =>
        db.JobApplications
            .Include(a => a.Job)
            .Include(a => a.Freelancer);

    static async Task<IResult> GetApplicationsForJob(Guid jobId, AppDbContext db)
    {
        if (!await db.Jobs.AnyAsync(j => j.Id == jobId)) return ApiError.NotFound("Job not found.");

        var applications = await ApplicationsWithDetails(db)
            .Where(a => a.JobId == jobId)
            .OrderBy(a => a.CreatedAt)
            .ToListAsync();
        return Results.Ok(applications.Select(a => a.ToDto()));
    }

     // "My Work" for a freelancer: /api/applications?freelancerId=...
    static async Task<IResult> GetApplicationsForFreelancer(Guid freelancerId, AppDbContext db)
    {
        var applications = await ApplicationsWithDetails(db)
            .Where(a => a.FreelancerId == freelancerId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();
        return Results.Ok(applications.Select(a => a.ToDto()));
    }

    static async Task<IResult> Apply(Guid jobId, ApplyRequest request, AppDbContext db)
    {
        if (string.IsNullOrWhiteSpace(request.Message) || request.Message.Length > 500)
            return ApiError.BadRequest("Message is required and must be 500 characters or fewer.");

        var freelancer = await db.Users.FindAsync(request.FreelancerId);
        if (freelancer is null || freelancer.Role != UserRole.Freelancer)
            return ApiError.Forbidden("Only freelancers can apply for jobs.");

        var job = await db.Jobs.Include(j => j.Applications).FirstOrDefaultAsync(j => j.Id == jobId);
        if (job is null) return ApiError.NotFound("Job not found.");
        if (!job.CanApply()) return ApiError.BadRequest("This job is no longer taking applications.");
        // Also blocks reapplying after a withdraw. The unique index in the database is the backup.
        if (job.HasApplicationFrom(request.FreelancerId)) return ApiError.Conflict("You've already applied for this job.");

        var application = new JobApplication
        {
            Id = Guid.NewGuid(),
            JobId = jobId,
            FreelancerId = request.FreelancerId,
            Message = request.Message.Trim(),
            CreatedAt = DateTimeOffset.UtcNow
        };

        db.JobApplications.Add(application);
        await db.SaveChangesAsync();

        var created = await ApplicationsWithDetails(db).FirstAsync(a => a.Id == application.Id);
        return Results.Created($"/api/applications/{application.Id}", created.ToDto());
    }

     // The client picks this freelancer. The job becomes Assigned.
    static async Task<IResult> Accept(Guid id, ActorRequest request, AppDbContext db)
    {
        // Load the job and all its applications, because accepting one rejects the others.
        var application = await db.JobApplications
            .Include(a => a.Job).ThenInclude(j => j.Applications)
            .FirstOrDefaultAsync(a => a.Id == id);
        if (application is null) return ApiError.NotFound("Application not found.");

        var job = application.Job;
        if (job.ClientId != request.UserId) return ApiError.Forbidden("Only the client who posted this job can accept applications.");
        if (!job.CanAccept(application)) return ApiError.BadRequest("This application can't be accepted any more.");

        job.Accept(application);
        await db.SaveChangesAsync();
        return Results.NoContent();
    }

    static async Task<IResult> Withdraw(Guid id, ActorRequest request, AppDbContext db)
    {
        var application = await db.JobApplications.FindAsync(id);
        if (application is null) return ApiError.NotFound("Application not found.");
        if (application.FreelancerId != request.UserId) return ApiError.Forbidden("You can only withdraw your own application.");
        if (!application.CanWithdraw()) return ApiError.BadRequest("Only a pending application can be withdrawn.");

        application.Withdraw();
        await db.SaveChangesAsync();
        return Results.NoContent();
    }

}
