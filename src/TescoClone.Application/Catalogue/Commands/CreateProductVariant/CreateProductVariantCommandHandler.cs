using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.CreateProductVariant;

public sealed class CreateProductVariantCommandHandler : IRequestHandler<CreateProductVariantCommand, int>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public CreateProductVariantCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<int> Handle(CreateProductVariantCommand request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.CreateProductVariantAsync(
            request.ProductId,
            request.Sku,
            request.VariantName,
            request.Barcode,
            request.InitialQuantity,
            request.LowStockThreshold,
            request.AdminUserId,
            cancellationToken);
}
