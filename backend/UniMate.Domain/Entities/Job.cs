using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class Job
{
    public Guid Id { get; set; }

    public Guid ClientId { get; set; }
    public User Client { get; set; } = null!;

    public Guid CategoryId { get; set; }
    public Category Category { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal? Budget { get; set; }
    public DateTimeOffset ScheduledAt { get; set; }
    public decimal? DurationHours { get; set; }

    public string Suburb { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }

    public Guid? RequiredLanguageId { get; set; }
    public Language? RequiredLanguage { get; set; }

    public JobStatus Status { get; set; } = JobStatus.Open;

    // Replaces a separate JobAssignment table: a job has at most one freelancer.
    public Guid? AssignedFreelancerId { get; set; }
    public User? AssignedFreelancer { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public DateTimeOffset? AssignedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }

    public List<JobApplication> Applications { get; set; } = new();
    public List<Offer> Offers { get; set; } = new();
}