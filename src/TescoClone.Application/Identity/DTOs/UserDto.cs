namespace TescoClone.Application.Identity.DTOs;

public sealed record UserDto(
    int Id,
    string FirstName,
    string LastName,
    string Email,
    string? PhoneNumber,
    IReadOnlyList<string> Roles);
