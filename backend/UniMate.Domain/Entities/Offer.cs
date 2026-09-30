using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class Offer
{
    public Guid Id { get; set; }

    public Guid JobId { get; set; }
    public Job Job { get; set; } = null!;

    public Guid ClientId { get; set; }
    public User Client { get; set; } = null!;

    public Guid FreelancerId { get; set; }
    public User Freelancer { get; set; } = null!;

    public decimal Amount { get; set; }
    public string? Message { get; set; }
    public OfferStatus Status { get; set; } = OfferStatus.Pending;

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? RespondedAt { get; set; }
}