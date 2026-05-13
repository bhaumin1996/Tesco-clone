using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Queries.GetOrderById;

public sealed record GetOrderByIdQuery(int OrderId) : IRequest<OrderDto>;
