using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public UserRole Role { get; set; }

    public bool IsSuspended { get; set; }
    public string? SuspendedReason { get; set; }
    public bool IsVerified { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? LastLoginAt { get; set; }

    // Navigation: a user has at most one of these, depending on Role.
    public ClientProfile? ClientProfile { get; set; }
    public FreelancerProfile? FreelancerProfile { get; set; }
}