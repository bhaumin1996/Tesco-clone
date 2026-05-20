namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerDeliveryOptionDto(
    int Id,
    int SellerId,
    string DeliveryType,
    decimal Price,
    decimal? FreeThresholdAmount,
    int EstimatedDaysMin,
    int EstimatedDaysMax,
    bool IsActive,
    DateTime CreatedOn,
    DateTime? ModifiedOn);

public sealed record UpsertDeliveryOptionDto(
    string DeliveryType,
    decimal Price,
    decimal? FreeThresholdAmount,
    int EstimatedDaysMin,
    int EstimatedDaysMax,
    bool IsActive);
