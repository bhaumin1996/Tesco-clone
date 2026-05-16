using MediatR;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;

namespace TescoClone.Application.Content.Queries.GetActiveBanners;

public sealed class GetActiveBannersQueryHandler : IRequestHandler<GetActiveBannersQuery, IReadOnlyList<BannerDto>>
{
    private readonly IContentRepository _contentRepository;

    public GetActiveBannersQueryHandler(IContentRepository contentRepository)
    {
        _contentRepository = contentRepository;
    }

    public Task<IReadOnlyList<BannerDto>> Handle(GetActiveBannersQuery request, CancellationToken cancellationToken) =>
        _contentRepository.GetActiveBannersForStorefrontAsync(cancellationToken);
}
