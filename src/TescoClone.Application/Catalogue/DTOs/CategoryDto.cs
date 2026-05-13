namespace TescoClone.Application.Catalogue.DTOs;

public sealed record CategoryDto(
    int Id,
    int DepartmentId,
    int? ParentCategoryId,
    string Name,
    string Slug,
    string? ImageUrl);
