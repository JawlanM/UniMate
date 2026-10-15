using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Data;

// Admins can't register through the app, so one is created when the API starts.
// The password comes from user-secrets (SeedAdmin:Password), never from the code.
public static class AdminSeeder
{
    public const string AdminEmail = "admin@unimate.app";

    public static async Task SeedAsync(WebApplication app)
    {
        var password = app.Configuration["SeedAdmin:Password"];
        if (string.IsNullOrWhiteSpace(password))
        {
            app.Logger.LogWarning("SeedAdmin:Password isn't set, so no admin user was created.");
            return;
        }

        // DbContext is "scoped" (one per request), so outside a request we make our own scope.
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher<User>>();

        if (await db.Users.AnyAsync(u => u.Role == UserRole.Admin)) return;

        var admin = new User
        {
            Id = Guid.NewGuid(),
            Email = AdminEmail,
            FirstName = "UniMate",
            LastName = "Admin",
            Role = UserRole.Admin,
            CreatedAt = DateTimeOffset.UtcNow
        };
        admin.PasswordHash = hasher.HashPassword(admin, password);

        db.Users.Add(admin);
        await db.SaveChangesAsync();
        app.Logger.LogInformation("Created admin user {Email}.", AdminEmail);
    }
}
