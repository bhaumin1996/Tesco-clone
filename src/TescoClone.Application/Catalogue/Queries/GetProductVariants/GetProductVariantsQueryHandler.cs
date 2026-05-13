using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Catalogue.Queries.GetProductVariants;

public sealed class GetProductVariantsQueryHandler : IRequestHandler<GetProductVariantsQuery, IReadOnlyList<ProductVariantDto>>
{
    private readonly IProductRepository _productRepository;

    public GetProductVariantsQueryHandler(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<IReadOnlyList<ProductVariantDto>> Handle(GetProductVariantsQuery request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.ProductId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Catalogue.Product), request.ProductId);

        return await _productRepository.GetVariantsAsync(request.ProductId, cancellationToken);
    }
}
