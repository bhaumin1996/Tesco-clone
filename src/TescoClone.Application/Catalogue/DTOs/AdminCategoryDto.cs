namespace TescoClone.Application.Catalogue.DTOs;

public sealed record AdminCategoryDto(
    int CategoryId,
    string Name,
    string Slug,
    string DepartmentName,
    int ProductCount,
    bool IsActive);
