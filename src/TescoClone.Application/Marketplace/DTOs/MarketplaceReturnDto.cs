namespace TescoClone.Application.Marketplace.DTOs;

public sealed record MarketplaceReturnDto(
    int Id,
    int OrderLineId,
    int SellerId,
    string? SellerName,
    int UserId,
    string ReturnReason,
    string? SellerResponse,
    string? Resolution,
    string StatusName,
    DateTime SlaDeadline,
    DateTime? ResolvedOn,
    decimal? RefundAmount,
    DateTime CreatedOn);
