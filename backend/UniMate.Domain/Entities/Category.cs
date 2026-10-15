namespace UniMate.Domain.Entities;

public class Category
{
    // int instead of Guid: categories are a small fixed list seeded by the migration.
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string IconName { get; set; } = string.Empty; // SF Symbol name used by the iOS app
}