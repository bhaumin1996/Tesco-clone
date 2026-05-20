namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerPayoutDto(
    int Id,
    int SellerId,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    decimal GrossSales,
    decimal CommissionDeducted,
    decimal NetPayout,
    string Status,
    DateTime? ProcessedOn,
    string? Reference,
    DateTime CreatedOn);

public sealed record RunPayoutResultDto(int Id, decimal NetPayout);
