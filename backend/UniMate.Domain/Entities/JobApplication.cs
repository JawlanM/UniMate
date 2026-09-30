using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

// Named JobApplication (not Application) so it doesn't clash with the
// UniMate.Application project namespace. The API still calls it "applications".
public class JobApplication
{
    public Guid Id { get; set; }

    public Guid JobId { get; set; }
    public Job Job { get; set; } = null!;

    public Guid FreelancerId { get; set; }
    public User Freelancer { get; set; } = null!;

    public string Message { get; set; } = string.Empty;
    public decimal? ProposedRate { get; set; }
    public ApplicationStatus Status { get; set; } = ApplicationStatus.Pending;

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? RespondedAt { get; set; }
}