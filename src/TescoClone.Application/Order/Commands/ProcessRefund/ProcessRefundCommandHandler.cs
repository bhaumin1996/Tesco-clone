using MediatR;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Commands.ProcessRefund;

public sealed class ProcessRefundCommandHandler : IRequestHandler<ProcessRefundCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IAdminOrderRepository _adminOrderRepository;

    public ProcessRefundCommandHandler(IOrderRepository orderRepository, IAdminOrderRepository adminOrderRepository)
    {
        _orderRepository = orderRepository;
        _adminOrderRepository = adminOrderRepository;
    }

    public async Task Handle(ProcessRefundCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken)
            ?? throw new NotFoundException("Order", request.OrderId.ToString());

        if (order.Status == OrderStatus.Refunded)
            throw new ConflictException("Order has already been refunded.");

        await _adminOrderRepository.ProcessRefundAsync(
            request.OrderId, request.RefundAmount, request.Reason, request.AdminUserId, cancellationToken);
    }
}
