namespace UniMate.Domain.Entities;

public class Language
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty; // ISO 639-1, e.g. "zh"
    public string Name { get; set; } = string.Empty; // "Chinese"
}