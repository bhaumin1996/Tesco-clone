using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Queries.GetCart;

public sealed record GetCartQuery(int UserId) : IRequest<CartDto?>;
