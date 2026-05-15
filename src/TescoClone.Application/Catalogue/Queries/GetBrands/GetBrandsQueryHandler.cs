using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetBrands;

public sealed class GetBrandsQueryHandler : IRequestHandler<GetBrandsQuery, IReadOnlyList<BrandDto>>
{
    private readonly IBrandRepository _brandRepository;

    public GetBrandsQueryHandler(IBrandRepository brandRepository)
    {
        _brandRepository = brandRepository;
    }

    public async Task<IReadOnlyList<BrandDto>> Handle(GetBrandsQuery request, CancellationToken cancellationToken)
    {
        return await _brandRepository.GetAllAsync(cancellationToken);
    }
}
