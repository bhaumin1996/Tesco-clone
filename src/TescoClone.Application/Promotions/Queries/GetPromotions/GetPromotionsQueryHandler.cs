using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;
using TescoClone.Application.Promotions.Interfaces;

namespace TescoClone.Application.Promotions.Queries.GetPromotions;

public sealed class GetPromotionsQueryHandler : IRequestHandler<GetPromotionsQuery, PaginatedResult<PromotionDto>>
{
    private readonly IPromotionRepository _promotionRepository;

    public GetPromotionsQueryHandler(IPromotionRepository promotionRepository)
    {
        _promotionRepository = promotionRepository;
    }

    public Task<PaginatedResult<PromotionDto>> Handle(GetPromotionsQuery request, CancellationToken cancellationToken) =>
        _promotionRepository.GetPromotionsAsync(request.IsActive, request.PageNumber, request.PageSize, cancellationToken);
}
