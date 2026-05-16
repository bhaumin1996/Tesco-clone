using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.CreateProduct;

public sealed class CreateProductCommandHandler : IRequestHandler<CreateProductCommand, int>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public CreateProductCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<int> Handle(CreateProductCommand request, CancellationToken cancellationToken)
    {
        var dto = new AdminProductDto(
            0, request.CategoryId, string.Empty,
            request.BrandId, null,
            request.Name, request.Slug, request.Description,
            request.BasePrice, request.ClubcardPrice, request.ImageUrl,
            request.IsAvailable, 0, DateTime.UtcNow, null,
            PlacedAndConfirmedCount: 0, PendingOrderCount: 0, RemainingStock: 0);

        return _adminCatalogueRepository.CreateProductAsync(dto, request.AdminUserId, cancellationToken);
    }
}
