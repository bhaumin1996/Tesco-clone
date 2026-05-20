namespace TescoClone.Application.Marketplace.DTOs;

public sealed record DisputeDto(
    int Id,
    int OrderId,
    int SellerId,
    string Subject,
    string Description,
    string StatusName,
    string? Resolution,
    DateTime CreatedOn,
    DateTime? ResolvedOn,
    string SellerName,
    string Reason);
