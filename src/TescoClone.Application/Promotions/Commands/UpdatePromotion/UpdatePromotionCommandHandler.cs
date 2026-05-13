using MediatR;
using TescoClone.Application.Promotions.DTOs;
using TescoClone.Application.Promotions.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Promotions.Commands.UpdatePromotion;

public sealed class UpdatePromotionCommandHandler : IRequestHandler<UpdatePromotionCommand>
{
    private readonly IPromotionRepository _promotionRepository;

    public UpdatePromotionCommandHandler(IPromotionRepository promotionRepository)
    {
        _promotionRepository = promotionRepository;
    }

    public async Task Handle(UpdatePromotionCommand request, CancellationToken cancellationToken)
    {
        var existing = await _promotionRepository.GetByIdAsync(request.PromotionId, cancellationToken)
            ?? throw new NotFoundException("Promotion", request.PromotionId.ToString());

        var dto = existing with
        {
            Name = request.Name,
            DiscountValue = request.DiscountValue,
            DiscountPercent = request.DiscountPercent,
            MinQuantity = request.MinQuantity,
            StartsAt = request.StartsAt,
            EndsAt = request.EndsAt,
            IsActive = request.IsActive,
            ModifiedOn = DateTime.UtcNow
        };

        await _promotionRepository.UpdateAsync(dto, request.AdminUserId, cancellationToken);
    }
}
