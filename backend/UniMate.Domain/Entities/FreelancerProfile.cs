using UniMate.Domain.Enums;

namespace UniMate.Domain.Entities;

public class FreelancerProfile
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public string? Headline { get; set; }
    public string? Bio { get; set; }
    public decimal? HourlyRate { get; set; }
    public string? Suburb { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? PhotoUrl { get; set; }

    public bool IsAvailable { get; set; } = true;
    public WeekDays AvailableDays { get; set; } = WeekDays.None;

    // Denormalised stats: stored copies kept up to date by the services,
    // so the matching algorithm doesn't recalculate them on every request.
    public double AverageRating { get; set; }
    public int ReviewCount { get; set; }
    public int CompletedJobsCount { get; set; }

    public List<FreelancerSkill> Skills { get; set; } = new();
    public List<FreelancerLanguage> Languages { get; set; } = new();
}