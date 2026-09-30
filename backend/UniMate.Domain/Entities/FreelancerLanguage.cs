namespace UniMate.Domain.Entities;

public class FreelancerLanguage
{
    public Guid FreelancerId { get; set; }
    public FreelancerProfile Freelancer { get; set; } = null!;

    public Guid LanguageId { get; set; }
    public Language Language { get; set; } = null!;
}