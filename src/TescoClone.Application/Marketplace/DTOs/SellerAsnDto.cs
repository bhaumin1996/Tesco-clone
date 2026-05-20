namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerAsnDto(
    int Id,
    int SellerId,
    DateOnly ExpectedArrivalDate,
    string SkusJson,
    string Status,
    string? Notes,
    DateTime CreatedOn);

public sealed record CreateAsnDto(
    DateOnly ExpectedArrivalDate,
    string SkusJson,
    string? Notes);
