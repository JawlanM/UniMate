namespace UniMate.Domain.Entities;

public class ClientProfile
{
    // Primary key AND foreign key to User: this makes it a strict 1-to-1.
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public string? Bio { get; set; }
    public string? University { get; set; }
    public string? Suburb { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? PhotoUrl { get; set; }
}