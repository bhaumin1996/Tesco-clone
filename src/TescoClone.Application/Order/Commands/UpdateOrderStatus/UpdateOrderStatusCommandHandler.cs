using MediatR;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.UpdateOrderStatus;

public sealed class UpdateOrderStatusCommandHandler : IRequestHandler<UpdateOrderStatusCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IAdminOrderRepository _adminOrderRepository;

    public UpdateOrderStatusCommandHandler(IOrderRepository orderRepository, IAdminOrderRepository adminOrderRepository)
    {
        _orderRepository = orderRepository;
        _adminOrderRepository = adminOrderRepository;
    }

    public async Task Handle(UpdateOrderStatusCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken)
            ?? throw new NotFoundException("Order", request.OrderId.ToString());

        await _adminOrderRepository.UpdateOrderStatusAsync(request.OrderId, request.NewStatus, request.AdminUserId, cancellationToken);
    }
}
