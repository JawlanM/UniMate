using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;
using UniMate.Api.Dtos;
using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var auth = app.MapGroup("/api/auth").WithTags("Auth");

        auth.MapPost("/register", Register);
        auth.MapPost("/login", Login);
    }

     static async Task<IResult> Register(RegisterRequest request, AppDbContext db, IPasswordHasher<User> hasher)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        if (!email.Contains('@')) return ApiError.BadRequest("Enter a valid email address.");
        if (request.Password.Length < 8) return ApiError.BadRequest("Password must be at least 8 characters.");
        if (string.IsNullOrWhiteSpace(request.FirstName) || string.IsNullOrWhiteSpace(request.LastName))
            return ApiError.BadRequest("Enter your first and last name.");
        // Nobody can sign themselves up as an admin.
        if (request.Role != UserRole.Client && request.Role != UserRole.Freelancer)
            return ApiError.BadRequest("Role must be Client or Freelancer.");

        if (await db.Users.AnyAsync(u => u.Email == email))
            return ApiError.Conflict("An account with this email already exists.");

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Role = request.Role,
            CreatedAt = DateTimeOffset.UtcNow
        };
        user.PasswordHash = hasher.HashPassword(user, request.Password);

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return Results.Json(user.ToDto(), statusCode: StatusCodes.Status201Created);
    }

    static async Task<IResult> Login(LoginRequest request, AppDbContext db, IPasswordHasher<User> hasher)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.FirstOrDefaultAsync(u => u.Email == email);

        // Same message for "no such email" and "wrong password", so the login
        // form can't be used to find out which emails have accounts.
        if (user is null || hasher.VerifyHashedPassword(user, user.PasswordHash, request.Password) == PasswordVerificationResult.Failed)
            return ApiError.Unauthorized("Email or password is incorrect.");

        return Results.Ok(user.ToDto());
    }




}
