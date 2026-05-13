using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Queries.GetMyOrders;

public sealed record GetMyOrdersQuery(int PageNumber = 1, int PageSize = 20) : IRequest<PaginatedResult<OrderDto>>;
