namespace TescoClone.Application.Promotions.DTOs;

public sealed record PromotionDto(
    int Id,
    string Name,
    string TypeName,
    decimal? DiscountValue,
    decimal? DiscountPercent,
    int? MinQuantity,
    DateTime? StartsAt,
    DateTime? EndsAt,
    bool IsActive,
    bool RequiresClubcard,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
