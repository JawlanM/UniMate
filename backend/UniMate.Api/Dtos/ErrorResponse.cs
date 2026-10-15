namespace UniMate.Api.Dtos;

// Every error the API returns has the same JSON shape: { "message": "..." }.
// The iOS app can show the message straight to the user.

public record ErrorResponse(string Message);

public static class ApiError
{
    public static IResult BadRequest(string message) => Results.BadRequest(new ErrorResponse(message));
    public static IResult Unauthorized(string message) => Results.Json(new ErrorResponse(message), statusCode: 401);
    public static IResult Forbidden(string message) => Results.Json(new ErrorResponse(message), statusCode: 403);
    public static IResult NotFound(string message) => Results.NotFound(new ErrorResponse(message));
    public static IResult Conflict(string message) => Results.Conflict(new ErrorResponse(message));
}