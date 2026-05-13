using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Queries.GetAllOrders;

public sealed class GetAllOrdersQueryHandler : IRequestHandler<GetAllOrdersQuery, PaginatedResult<OrderDto>>
{
    private readonly IAdminOrderRepository _adminOrderRepository;

    public GetAllOrdersQueryHandler(IAdminOrderRepository adminOrderRepository)
    {
        _adminOrderRepository = adminOrderRepository;
    }

    public Task<PaginatedResult<OrderDto>> Handle(GetAllOrdersQuery request, CancellationToken cancellationToken) =>
        _adminOrderRepository.GetAllOrdersAsync(request.Status, request.PageNumber, request.PageSize, cancellationToken);
}
