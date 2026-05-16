using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Catalogue.Queries.GetAdminProducts;

public sealed class GetAdminProductsQueryHandler : IRequestHandler<GetAdminProductsQuery, PaginatedResult<AdminProductDto>>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public GetAdminProductsQueryHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<PaginatedResult<AdminProductDto>> Handle(GetAdminProductsQuery request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.GetProductsAsync(
            request.Search,
            request.CategoryId,
            request.DepartmentId,
            request.PageNumber,
            request.PageSize,
            request.SortBy,
            request.SortDirection,
            cancellationToken);
}
