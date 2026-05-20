using MediatR;

namespace TescoClone.Application.Marketplace.Commands.ConfirmSellerOrder;

public sealed record ConfirmSellerOrderCommand(int SellerOrderId, int SellerId, int ModifiedBy) : IRequest;
