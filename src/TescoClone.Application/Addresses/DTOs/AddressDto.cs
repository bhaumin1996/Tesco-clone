namespace TescoClone.Application.Addresses.DTOs;

public sealed record AddressDto(
    int Id,
    int UserId,
    string AddressLine1,
    string? AddressLine2,
    string TownCity,
    string Postcode,
    bool IsDefault);
