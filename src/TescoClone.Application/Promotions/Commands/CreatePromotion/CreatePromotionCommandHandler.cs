using MediatR;
using TescoClone.Application.Promotions.DTOs;
using TescoClone.Application.Promotions.Interfaces;

namespace TescoClone.Application.Promotions.Commands.CreatePromotion;

public sealed class CreatePromotionCommandHandler : IRequestHandler<CreatePromotionCommand, int>
{
    private readonly IPromotionRepository _promotionRepository;

    public CreatePromotionCommandHandler(IPromotionRepository promotionRepository)
    {
        _promotionRepository = promotionRepository;
    }

    public Task<int> Handle(CreatePromotionCommand request, CancellationToken cancellationToken)
    {
        var dto = new PromotionDto(
            0, request.Name, string.Empty,
            request.DiscountValue, request.DiscountPercent,
            request.MinQuantity, request.StartsAt, request.EndsAt,
            true, DateTime.UtcNow, null);

        return _promotionRepository.CreateAsync(dto, request.AdminUserId, cancellationToken);
    }
}
