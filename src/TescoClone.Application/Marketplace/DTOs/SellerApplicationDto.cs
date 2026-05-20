namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerApplicationDto(
    int Id,
    int UserId,
    string BusinessName,
    string BusinessEmail,
    string? Phone,
    string? Description,
    string? RegistrationNumber,
    string? VatNumber,
    string? CategoryIds,
    bool TsAndCsAccepted,
    string StatusName,
    string? ReviewNotes,
    int? ReviewedBy,
    DateTime? ReviewedOn,
    DateTime CreatedOn,
    DateTime? ModifiedOn,
    string? Website);

public sealed record SellerApplicationListDto(
    int Id,
    int UserId,
    string BusinessName,
    string BusinessEmail,
    string? Phone,
    string StatusName,
    bool TsAndCsAccepted,
    string? ReviewNotes,
    DateTime? ReviewedOn,
    DateTime CreatedOn,
    DateTime? ModifiedOn,
    string? Website,
    string? RegistrationNumber = null,
    string? VatNumber = null,
    string? Description = null,
    string? BankDetailsRef = null,
    string? CategoryIds = null);

public sealed record ApplyAsSellerDto(
    string BusinessName,
    string BusinessEmail,
    string? Phone,
    string? Description,
    string? RegistrationNumber,
    string? VatNumber,
    string? BankDetailsRef,
    string? CategoryIds,
    bool TsAndCsAccepted,
    string? Website,
    string? ContactName = null);

public sealed record UpdateApplicationDto(
    string BusinessName,
    string BusinessEmail,
    string? Phone,
    string? Description,
    string? RegistrationNumber,
    string? VatNumber,
    string? BankDetailsRef,
    string? CategoryIds,
    bool TsAndCsAccepted,
    string? Website);
