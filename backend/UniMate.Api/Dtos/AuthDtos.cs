using UniMate.Domain.Entities;
using UniMate.Domain.Enums;

namespace UniMate.Api.Dtos;

public record RegisterRequest
(
    string Email, 
    string Password, 
    string FirstName, 
    string LastName, 
    UserRole Role
);

public record LoginRequest
(
    string Email, 
    string Password
);


// What the app gets back about a user. Never includes PasswordHash.
public record UserDto
(
    Guid Id, 
    string Email, 
    string FirstName, 
    string LastName, 
    UserRole Role
);

// Body for buttons like Accept or Withdraw: "this user is pressing it".
public record ActorRequest(Guid UserId);
public static class UserMapping
{
    public static UserDto ToDto(this User user) =>
        new
        (
            user.Id, 
            user.Email, 
            user.FirstName, 
            user.LastName, 
            user.Role
        );
}