namespace TescoClone.Application.Content.DTOs;

public sealed record PageDto(
    int Id,
    string Title,
    string Slug,
    string? Content,
    bool IsPublished,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
