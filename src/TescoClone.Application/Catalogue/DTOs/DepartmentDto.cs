namespace TescoClone.Application.Catalogue.DTOs;

public sealed record DepartmentDto(
    int Id,
    string Name,
    string Slug,
    string? ImageUrl,
    int DisplayOrder);
