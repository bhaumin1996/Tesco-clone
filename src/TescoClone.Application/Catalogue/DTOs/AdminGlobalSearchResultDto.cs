using System.Collections.Generic;

namespace TescoClone.Application.Catalogue.DTOs;

public sealed record SearchProductItemDto(int ProductId, string Name, string Slug, string? ImageUrl, decimal BasePrice);
public sealed record SearchCategoryItemDto(int CategoryId, string Name, string Slug, string? ImageUrl);
public sealed record SearchDepartmentItemDto(int DepartmentId, string Name, string Slug, string? ImageUrl);
public sealed record SearchBrandItemDto(int BrandId, string Name, string Slug, string? LogoUrl);
public sealed record SearchOrderItemDto(int OrderId, string OrderNumber, decimal TotalAmount);
public sealed record SearchUserItemDto(int UserId, string FirstName, string LastName, string Email);

public sealed class AdminGlobalSearchResultDto
{
    public List<SearchProductItemDto> Products { get; set; } = new();
    public List<SearchCategoryItemDto> Categories { get; set; } = new();
    public List<SearchDepartmentItemDto> Departments { get; set; } = new();
    public List<SearchBrandItemDto> Brands { get; set; } = new();
    public List<SearchOrderItemDto> Orders { get; set; } = new();
    public List<SearchUserItemDto> Users { get; set; } = new();
}
