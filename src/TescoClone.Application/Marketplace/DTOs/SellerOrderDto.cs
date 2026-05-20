namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerOrderSummaryDto(
    int Id,
    int OrderId,
    string OrderNumber,
    string StatusName,
    string? CarrierName,
    string? TrackingNumber,
    DateTime? ConfirmedOn,
    DateTime? DispatchedOn,
    int LineCount,
    decimal SellerTotal,
    DateTime OrderPlacedOn);

public sealed record SellerOrderDto(
    int Id,
    int OrderId,
    string OrderNumber,
    string StatusName,
    string? CarrierName,
    string? TrackingNumber,
    DateTime? ConfirmedOn,
    DateTime? DispatchedOn,
    DateTime OrderPlacedOn,
    string? DeliveryAddress,
    IReadOnlyList<SellerOrderLineDto> Items);

public sealed record SellerOrderLineDto(
    int Id,
    int ProductId,
    string ProductName,
    string? ImageUrl,
    decimal Price,
    int Quantity,
    decimal LineTotal,
    int? ListingId,
    int? SellerId);
