using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Queries.GetAllOrders;

public sealed record GetAllOrdersQuery(
    OrderStatus? Status,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<OrderDto>>;
