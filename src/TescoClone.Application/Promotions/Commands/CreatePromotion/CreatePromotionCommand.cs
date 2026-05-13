using MediatR;

namespace TescoClone.Application.Promotions.Commands.CreatePromotion;

public sealed record CreatePromotionCommand(
    string Name,
    int PromotionTypeId,
    decimal? DiscountValue,
    decimal? DiscountPercent,
    int? MinQuantity,
    DateTime? StartsAt,
    DateTime? EndsAt,
    int AdminUserId) : IRequest<int>;
