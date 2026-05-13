using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Commands.CancelOrder;

public sealed class CancelOrderCommandHandler : IRequestHandler<CancelOrderCommand>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUser _currentUser;

    public CancelOrderCommandHandler(IOrderRepository orderRepository, ICurrentUser currentUser)
    {
        _orderRepository = orderRepository;
        _currentUser = currentUser;
    }

    public async Task Handle(CancelOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Order.Order), request.OrderId);

        if (order.Status is OrderStatus.Delivered or OrderStatus.Cancelled or OrderStatus.Refunded)
            throw new ConflictException($"Cannot cancel an order with status '{order.Status}'.");

        await _orderRepository.UpdateStatusAsync(request.OrderId, OrderStatus.Cancelled, _currentUser.UserId, cancellationToken);
    }
}
