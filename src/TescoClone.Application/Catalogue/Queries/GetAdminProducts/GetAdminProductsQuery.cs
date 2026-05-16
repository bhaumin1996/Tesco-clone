using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Catalogue.Queries.GetAdminProducts;

public sealed record GetAdminProductsQuery(
    string? Search,
    int? CategoryId,
    int? DepartmentId,
    int PageNumber = 1,
    int PageSize = 10,
    string SortBy = "createdOn",
    string SortDirection = "desc") : IRequest<PaginatedResult<AdminProductDto>>;
