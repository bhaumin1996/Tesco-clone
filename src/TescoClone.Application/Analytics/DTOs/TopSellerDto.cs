namespace TescoClone.Application.Analytics.DTOs;

public sealed record TopSellerDto(
    int SellerId,
    string BusinessName,
    decimal Revenue,
    int OrderCount);
