using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Catalogue.Queries.SearchProducts;

public sealed record SearchProductsQuery(
    string? SearchTerm,
    int? CategoryId,
    int? BrandId,
    decimal? MinPrice,
    decimal? MaxPrice,
    bool? InStockOnly,
    string? SortBy,
    string? SortDirection,
    int PageNumber = 1,
    int PageSize = 20) : IRequest<PaginatedResult<ProductDto>>;
