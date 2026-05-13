using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Delivery.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Delivery.Commands.BookDeliverySlot;

public sealed class BookDeliverySlotCommandHandler : IRequestHandler<BookDeliverySlotCommand>
{
    private readonly IDeliveryRepository _deliveryRepository;
    private readonly ICurrentUser _currentUser;

    public BookDeliverySlotCommandHandler(IDeliveryRepository deliveryRepository, ICurrentUser currentUser)
    {
        _deliveryRepository = deliveryRepository;
        _currentUser = currentUser;
    }

    public async Task Handle(BookDeliverySlotCommand request, CancellationToken cancellationToken)
    {
        var slot = await _deliveryRepository.GetSlotByIdAsync(request.SlotId, cancellationToken)
            ?? throw new NotFoundException("DeliverySlot", request.SlotId);

        if (!slot.HasCapacity)
            throw new ConflictException("This delivery slot is fully booked. Please choose another slot.");

        await _deliveryRepository.BookSlotAsync(request.SlotId, request.OrderId, _currentUser.UserId, cancellationToken);
    }
}
