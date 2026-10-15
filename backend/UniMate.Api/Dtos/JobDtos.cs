using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Dtos;

public record CategoryDto
(
    int Id, 
    string Name, 
    string IconName
);

public record CreateJobRequest
(
    Guid ClientId,
    int CategoryId,
    string Title,
    string Description,
    decimal Budget,
    string Suburb,
    DateTimeOffset ScheduledAt
);

public record JobDto
(
    Guid Id,
    Guid ClientId,
    string ClientName,
    int CategoryId,
    string CategoryName,
    string Title,
    string Description,
    decimal Budget,
    string Suburb,
    DateTimeOffset ScheduledAt,
    JobStatus Status,
    Guid? AssignedFreelancerId,
    string? AssignedFreelancerName,
    int ApplicationCount,
    DateTimeOffset CreatedAt,
    DateTimeOffset? CompletedAt
);

public record ApplyRequest
(
    Guid FreelancerId, 
    string Message
);

public record ApplicationDto
(
    Guid Id,
    Guid JobId,
    string JobTitle,
    JobStatus JobStatus,
    Guid FreelancerId,
    string FreelancerName,
    string Message,
    ApplicationStatus Status,
    DateTimeOffset CreatedAt
);


// These ToDto methods need the related rows loaded first (Include in the query).
public static class JobMapping
{
    public static CategoryDto ToDto(this Category category) =>
        new
        (
            category.Id, 
            category.Name, 
            category.IconName
        );

    public static JobDto ToDto(this Job job) =>
        new
        (
            job.Id,
            job.ClientId,
            $"{job.Client.FirstName} {job.Client.LastName}",
            job.CategoryId,
            job.Category.Name,
            job.Title,
            job.Description,
            job.Budget,
            job.Suburb,
            job.ScheduledAt,
            job.Status,
            job.AssignedFreelancerId,
            job.AssignedFreelancer is null ? null : $"{job.AssignedFreelancer.FirstName} {job.AssignedFreelancer.LastName}",
            job.Applications.Count,
            job.CreatedAt,
            job.CompletedAt
        );

    public static ApplicationDto ToDto(this JobApplication application) =>
        new
        (
            application.Id,
            application.JobId,
            application.Job.Title,
            application.Job.Status,
            application.FreelancerId,
            $"{application.Freelancer.FirstName} {application.Freelancer.LastName}",
            application.Message,
            application.Status,
            application.CreatedAt
        );
}
