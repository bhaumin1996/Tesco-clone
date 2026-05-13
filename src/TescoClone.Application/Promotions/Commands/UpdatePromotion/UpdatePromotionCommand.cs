using MediatR;

namespace TescoClone.Application.Promotions.Commands.UpdatePromotion;

public sealed record UpdatePromotionCommand(
    int PromotionId,
    string Name,
    decimal? DiscountValue,
    decimal? DiscountPercent,
    int? MinQuantity,
    DateTime? StartsAt,
    DateTime? EndsAt,
    bool IsActive,
    int AdminUserId) : IRequest;
