using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.AdjustInventory;

public sealed class AdjustInventoryCommandHandler : IRequestHandler<AdjustInventoryCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public AdjustInventoryCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task Handle(AdjustInventoryCommand request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.AdjustInventoryAsync(
            request.ProductVariantId, request.QuantityDelta, request.AdminUserId, cancellationToken);
}
