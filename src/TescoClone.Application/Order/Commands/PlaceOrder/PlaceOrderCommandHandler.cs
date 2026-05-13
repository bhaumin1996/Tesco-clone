using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.PlaceOrder;

public sealed class PlaceOrderCommandHandler : IRequestHandler<PlaceOrderCommand, OrderDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUser _currentUser;

    public PlaceOrderCommandHandler(
        ICartRepository cartRepository,
        IOrderRepository orderRepository,
        ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _orderRepository = orderRepository;
        _currentUser = currentUser;
    }

    public async Task<OrderDto> Handle(PlaceOrderCommand request, CancellationToken cancellationToken)
    {
        var cart = await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new ConflictException("Cannot place an order with an empty cart.");

        if (cart.Items.Count == 0)
            throw new ConflictException("Cannot place an order with an empty cart.");

        var orderId = await _orderRepository.CreateFromCartAsync(
            _currentUser.UserId,
            request.DeliverySlotId,
            request.DeliveryAddress,
            request.DeliveryCharge,
            _currentUser.UserId,
            cancellationToken);

        await _cartRepository.ClearAsync(_currentUser.UserId, _currentUser.UserId, cancellationToken);

        return await _orderRepository.GetByIdAsync(orderId, cancellationToken)
            ?? throw new InvalidOperationException("Order not found after creation.");
    }
}
