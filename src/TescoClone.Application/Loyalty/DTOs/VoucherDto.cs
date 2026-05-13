namespace TescoClone.Application.Loyalty.DTOs;

public sealed record VoucherDto(
    int Id,
    string Code,
    decimal DiscountAmount,
    decimal? MinimumSpend,
    DateTime ValidFrom,
    DateTime ValidTo,
    bool IsRedeemed);
