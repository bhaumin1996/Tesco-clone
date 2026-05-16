using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Catalogue.Commands.UpdateProduct;

public sealed class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;
    private readonly IProductRepository _productRepository;

    public UpdateProductCommandHandler(IAdminCatalogueRepository adminCatalogueRepository, IProductRepository productRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
        _productRepository = productRepository;
    }

    public async Task Handle(UpdateProductCommand request, CancellationToken cancellationToken)
    {
        var existing = await _productRepository.GetByIdAsync(request.ProductId, cancellationToken)
            ?? throw new NotFoundException("Product", request.ProductId.ToString());

        var dto = new AdminProductDto(
            request.ProductId, request.CategoryId, string.Empty,
            request.BrandId, null,
            request.Name, existing.Slug, request.Description,
            request.BasePrice, request.ClubcardPrice, request.ImageUrl,
            request.IsAvailable, 0, DateTime.UtcNow, DateTime.UtcNow,
            PlacedAndConfirmedCount: 0, PendingOrderCount: 0, RemainingStock: 0);

        await _adminCatalogueRepository.UpdateProductAsync(dto, request.AdminUserId, cancellationToken);
    }
}
