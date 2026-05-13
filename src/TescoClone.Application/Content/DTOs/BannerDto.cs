namespace TescoClone.Application.Content.DTOs;

public sealed record BannerDto(
    int Id,
    string Title,
    string? SubTitle,
    string? ImageUrl,
    string? LinkUrl,
    int DisplayOrder,
    bool IsActive,
    DateTime? StartsAt,
    DateTime? EndsAt,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
