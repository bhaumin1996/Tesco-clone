using MediatR;

namespace TescoClone.Application.Order.Commands.RemoveCartItem;

public sealed record RemoveCartItemCommand(int ProductVariantId) : IRequest;
