using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;
using TescoClone.Application.Promotions.Interfaces;

namespace TescoClone.Application.Promotions.Queries.GetActivePromotions;

public sealed class GetActivePromotionsQueryHandler : IRequestHandler<GetActivePromotionsQuery, PaginatedResult<PromotionDto>>
{
    private readonly IPromotionRepository _promotionRepository;

    public GetActivePromotionsQueryHandler(IPromotionRepository promotionRepository)
    {
        _promotionRepository = promotionRepository;
    }

    public Task<PaginatedResult<PromotionDto>> Handle(GetActivePromotionsQuery request, CancellationToken cancellationToken) =>
        _promotionRepository.GetActivePromotionsForStorefrontAsync(request.PageNumber, request.PageSize, cancellationToken);
}
