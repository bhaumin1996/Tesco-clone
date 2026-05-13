using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Queries.GetMyOrders;

public sealed class GetMyOrdersQueryHandler : IRequestHandler<GetMyOrdersQuery, PaginatedResult<OrderDto>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUser _currentUser;

    public GetMyOrdersQueryHandler(IOrderRepository orderRepository, ICurrentUser currentUser)
    {
        _orderRepository = orderRepository;
        _currentUser = currentUser;
    }

    public Task<PaginatedResult<OrderDto>> Handle(GetMyOrdersQuery request, CancellationToken cancellationToken) =>
        _orderRepository.GetByUserIdAsync(_currentUser.UserId, request.PageNumber, request.PageSize, cancellationToken);
}
