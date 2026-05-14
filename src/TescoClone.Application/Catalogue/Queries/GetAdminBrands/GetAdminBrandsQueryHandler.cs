using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetAdminBrands;

public sealed class GetAdminBrandsQueryHandler : IRequestHandler<GetAdminBrandsQuery, IReadOnlyList<AdminBrandDto>>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public GetAdminBrandsQueryHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<IReadOnlyList<AdminBrandDto>> Handle(GetAdminBrandsQuery request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.GetBrandsAsync(cancellationToken);
}
