using MediatR;

namespace TescoClone.Application.Marketplace.Commands.DispatchSellerOrder;

public sealed record DispatchSellerOrderCommand(
    int SellerOrderId,
    int SellerId,
    string CarrierName,
    string TrackingNumber,
    int ModifiedBy) : IRequest;
