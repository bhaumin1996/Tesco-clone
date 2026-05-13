namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerDto(
    int Id,
    string BusinessName,
    string ContactEmail,
    string StatusName,
    decimal CommissionRate,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
