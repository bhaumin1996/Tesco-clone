using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetAdminInventory;

public sealed class GetAdminInventoryQueryHandler : IRequestHandler<GetAdminInventoryQuery, IReadOnlyList<AdminInventoryDto>>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public GetAdminInventoryQueryHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<IReadOnlyList<AdminInventoryDto>> Handle(GetAdminInventoryQuery request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.GetInventoryAsync(cancellationToken);
}
