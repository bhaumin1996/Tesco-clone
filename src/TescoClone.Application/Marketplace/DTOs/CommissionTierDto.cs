namespace TescoClone.Application.Marketplace.DTOs;

public sealed record CommissionTierDto(
    int Id,
    string Name,
    int? CategoryId,
    string? CategoryName,
    decimal Rate,
    bool IsDefault,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
