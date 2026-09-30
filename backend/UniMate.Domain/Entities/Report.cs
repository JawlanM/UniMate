using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class Report
{
    public Guid Id { get; set; }

    public Guid ReporterId { get; set; }
    public User Reporter { get; set; } = null!;

    // At least one target must be set (DB check constraint in 2b).
    public Guid? ReportedUserId { get; set; }
    public User? ReportedUser { get; set; }

    public Guid? JobId { get; set; }
    public Job? Job { get; set; }

    public ReportReason Reason { get; set; }
    public string Details { get; set; } = string.Empty;

    public ReportStatus Status { get; set; } = ReportStatus.Open;
    public string? AdminNote { get; set; }
    public Guid? ResolvedById { get; set; }
    public User? ResolvedBy { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? ResolvedAt { get; set; }
}
