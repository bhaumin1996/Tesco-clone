namespace TescoClone.Application.Catalogue.DTOs;

public sealed record AdminCategoryDto(
    int CategoryId,
    string Name,
    string Slug,
    int DepartmentId,
    string DepartmentName,
    int ProductCount,
    bool IsActive,
    string? ImageUrl,
    DateTime CreatedOn);
