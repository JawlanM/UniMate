namespace UniMate.Domain.Entities;

public class Category
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;     // "moving": stable, URL-friendly
    public string IconName { get; set; } = string.Empty; // SF Symbol name for the iOS app
    public int SortOrder { get; set; }

    public List<Skill> Skills { get; set; } = new();
}