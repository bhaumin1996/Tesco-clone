using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Commands.AddToCart;

public sealed record AddToCartCommand(
    int ProductVariantId,
    int Quantity) : IRequest<CartDto>;
