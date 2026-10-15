using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;
using UniMate.Api.Dtos;
using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Endpoints;

public static class JobEndpoints
{
    public static void MapJobEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/categories", GetCategories).WithTags("Categories");

        var jobs = app.MapGroup("/api/jobs").WithTags("Jobs");

        jobs.MapGet("/", GetJobs);
        jobs.MapGet("/{id:guid}", GetJob);
        jobs.MapPost("/", CreateJob);
        jobs.MapPost("/{id:guid}/complete", CompleteJob);
        jobs.MapPost("/{id:guid}/cancel", CancelJob);
    }

     // Jobs with everything JobDto needs (client, category, freelancer, applications).
    static IQueryable<Job> JobsWithDetails(AppDbContext db) =>
        db.Jobs
            .Include(j => j.Client)
            .Include(j => j.Category)
            .Include(j => j.AssignedFreelancer)
            .Include(j => j.Applications);

    static async Task<IResult> GetCategories(AppDbContext db)
    {
        var categories = await db.Categories.OrderBy(c => c.Id).ToListAsync();
        return Results.Ok(categories.Select(c => c.ToDto()));
    }

     // Every filter is optional: /api/jobs?status=Open&categoryId=2 for browsing,
    // /api/jobs?clientId=... for "My Jobs".
    static async Task<IResult> GetJobs(AppDbContext db, JobStatus? status, int? categoryId, Guid? clientId)
    {
        var query = JobsWithDetails(db);

        if (status is not null) query = query.Where(j => j.Status == status);
        if (categoryId is not null) query = query.Where(j => j.CategoryId == categoryId);
        if (clientId is not null) query = query.Where(j => j.ClientId == clientId);

        var jobs = await query.OrderByDescending(j => j.CreatedAt).ToListAsync();
        return Results.Ok(jobs.Select(j => j.ToDto()));
    }

     static async Task<IResult> GetJob(Guid id, AppDbContext db)
    {
        var job = await JobsWithDetails(db).FirstOrDefaultAsync(j => j.Id == id);
        return job is null ? ApiError.NotFound("Job not found.") : Results.Ok(job.ToDto());
    }

    static async Task<IResult> CreateJob(CreateJobRequest request, AppDbContext db)
    {
        if (string.IsNullOrWhiteSpace(request.Title) || request.Title.Length > 80)
            return ApiError.BadRequest("Title is required and must be 80 characters or fewer.");
        if (string.IsNullOrWhiteSpace(request.Description) || request.Description.Length > 1000)
            return ApiError.BadRequest("Description is required and must be 1000 characters or fewer.");
        if (request.Budget <= 0 || request.Budget > 10000)
            return ApiError.BadRequest("Budget must be between $1 and $10,000.");
        if (string.IsNullOrWhiteSpace(request.Suburb))
            return ApiError.BadRequest("Suburb is required.");
        if (request.ScheduledAt < DateTimeOffset.UtcNow)
            return ApiError.BadRequest("The job can't be scheduled in the past.");

        var client = await db.Users.FindAsync(request.ClientId);
        if (client is null || client.Role != UserRole.Client)
            return ApiError.Forbidden("Only clients can post jobs.");
        if (!await db.Categories.AnyAsync(c => c.Id == request.CategoryId))
            return ApiError.BadRequest("Pick a category.");

        var job = new Job
        {
            Id = Guid.NewGuid(),
            ClientId = request.ClientId,
            CategoryId = request.CategoryId,
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            Budget = request.Budget,
            Suburb = request.Suburb.Trim(),
            // PostgreSQL stores times in UTC, and Npgsql refuses any other offset.
            ScheduledAt = request.ScheduledAt.ToUniversalTime(),
            CreatedAt = DateTimeOffset.UtcNow
        };

        db.Jobs.Add(job);
        await db.SaveChangesAsync();

        // Load it back with the client and category so the response has their names.
        var created = await JobsWithDetails(db).FirstAsync(j => j.Id == job.Id);
        return Results.Created($"/api/jobs/{job.Id}", created.ToDto());
    }

    static async Task<IResult> CompleteJob(Guid id, ActorRequest request, AppDbContext db)
    {
        var job = await db.Jobs.FindAsync(id);
        if (job is null) return ApiError.NotFound("Job not found.");
        if (job.ClientId != request.UserId) return ApiError.Forbidden("Only the client who posted this job can complete it.");
        if (!job.CanComplete()) return ApiError.BadRequest("Only an assigned job can be completed.");

        job.Complete(DateTimeOffset.UtcNow);
        await db.SaveChangesAsync();
        return Results.NoContent();
    }

      static async Task<IResult> CancelJob(Guid id, ActorRequest request, AppDbContext db)
    {
        // Applications are needed because cancelling rejects the pending ones.
        var job = await db.Jobs.Include(j => j.Applications).FirstOrDefaultAsync(j => j.Id == id);
        if (job is null) return ApiError.NotFound("Job not found.");
        if (job.ClientId != request.UserId) return ApiError.Forbidden("Only the client who posted this job can cancel it.");
        if (!job.CanCancel()) return ApiError.BadRequest("Only an open job can be cancelled.");

        job.Cancel();
        await db.SaveChangesAsync();
        return Results.NoContent();
    }



}
