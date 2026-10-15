using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

// A user flags a job for an admin to look at.
public class Report
{
    public Guid Id { get; set; }

    public Guid ReporterId { get; set; }
    public User Reporter { get; set; } = null!;

    public Guid JobId { get; set; }
    public Job Job { get; set; } = null!;

    public ReportReason Reason { get; set; }
    public string Details { get; set; } = string.Empty;
    public ReportStatus Status { get; set; } = ReportStatus.Open;
    public DateTimeOffset CreatedAt { get; set; }
}