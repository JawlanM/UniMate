namespace UniMate.Domain.Entities;

public class Review
{
    public Guid Id { get; set; }

    public Guid JobId { get; set; }
    public Job Job { get; set; } = null!;

    public Guid ReviewerId { get; set; }
    public User Reviewer { get; set; } = null!;

    public Guid FreelancerId { get; set; }
    public User Freelancer { get; set; } = null!;

    public int Rating { get; set; } // 1–5, enforced by a DB check constraint in 2b
    public string? Comment { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}
