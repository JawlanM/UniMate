using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class Job
{
    public Guid Id { get; set; }

    // The client who posted the job.
    public Guid ClientId { get; set; }
    public User Client { get; set; } = null!;

    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Budget { get; set; }
    public string Suburb { get; set; } = string.Empty;
    public DateTimeOffset ScheduledAt { get; set; }

    public JobStatus Status { get; set; } = JobStatus.Open;

    // Set when the client accepts an application. A job has at most one freelancer.
    public Guid? AssignedFreelancerId { get; set; }
    public User? AssignedFreelancer { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }

    public List<JobApplication> Applications { get; set; } = new();
}