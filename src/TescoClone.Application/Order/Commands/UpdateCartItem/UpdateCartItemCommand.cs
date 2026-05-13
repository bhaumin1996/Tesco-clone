using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Commands.UpdateCartItem;

public sealed record UpdateCartItemCommand(int ProductVariantId, int Quantity) : IRequest<CartDto>;
