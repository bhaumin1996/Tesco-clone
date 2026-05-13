namespace TescoClone.Application.Identity.DTOs;

public sealed record AdminUserDto(
    int Id,
    string FirstName,
    string LastName,
    string Email,
    string? PhoneNumber,
    string StatusName,
    byte FailedLoginAttempts,
    DateTime? LockedUntil,
    IReadOnlyList<string> Roles,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
