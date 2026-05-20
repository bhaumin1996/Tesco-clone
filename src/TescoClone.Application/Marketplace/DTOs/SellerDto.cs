namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerDto(
    int Id,
    string BusinessName,
    string ContactEmail,
    string StatusName,
    decimal CommissionRate,
    string? RegistrationNumber,
    string? VatNumber,
    string? Phone,
    string? Description,
    string? BankDetailsRef,
    int? CommissionTierId,
    DateTime? ApprovedOn,
    DateTime? SuspendedOn,
    DateTime CreatedOn,
    DateTime? ModifiedOn,
    string? Website,
    int TotalListings);
