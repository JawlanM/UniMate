using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

// Named JobApplication (not Application) so it doesn't clash with the word
// "Application" used all over .NET. The API still calls it "applications".
public class JobApplication
{
    public Guid Id { get; set; }

    public Guid JobId { get; set; }
    public Job Job { get; set; } = null!;

    public Guid FreelancerId { get; set; }
    public User Freelancer { get; set; } = null!;

    public string Message { get; set; } = string.Empty;
    public ApplicationStatus Status { get; set; } = ApplicationStatus.Pending;
    public DateTimeOffset CreatedAt { get; set; }


    // Only a pending application can be withdrawn. Withdrawing is final.
    public bool CanWithdraw() => Status == ApplicationStatus.Pending;

    public void Withdraw()
    {
        if (!CanWithdraw()) throw new InvalidOperationException("Only a pending application can be withdrawn.");

        Status = ApplicationStatus.Withdrawn;
    }
}
