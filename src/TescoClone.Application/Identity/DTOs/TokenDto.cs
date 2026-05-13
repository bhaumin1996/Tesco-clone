namespace TescoClone.Application.Identity.DTOs;

public sealed record TokenDto(
    string AccessToken,
    DateTime ExpiresAt,
    string RefreshToken);
