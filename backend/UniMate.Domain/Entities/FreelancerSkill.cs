namespace UniMate.Domain.Entities;

// Join table: many freelancers <-> many skills.
public class FreelancerSkill
{
    public Guid FreelancerId { get; set; }
    public FreelancerProfile Freelancer { get; set; } = null!;

    public Guid SkillId { get; set; }
    public Skill Skill { get; set; } = null!;
}