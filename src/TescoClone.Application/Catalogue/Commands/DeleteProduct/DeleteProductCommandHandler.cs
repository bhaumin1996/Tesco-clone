using MediatR;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Catalogue.Commands.DeleteProduct;

public sealed class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;
    private readonly IProductRepository _productRepository;

    public DeleteProductCommandHandler(IAdminCatalogueRepository adminCatalogueRepository, IProductRepository productRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
        _productRepository = productRepository;
    }

    public async Task Handle(DeleteProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.ProductId, cancellationToken)
            ?? throw new NotFoundException("Product", request.ProductId.ToString());

        await _adminCatalogueRepository.SoftDeleteProductAsync(request.ProductId, request.AdminUserId, cancellationToken);
    }
}
