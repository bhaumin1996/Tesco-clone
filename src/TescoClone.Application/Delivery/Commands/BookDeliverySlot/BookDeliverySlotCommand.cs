using MediatR;

namespace TescoClone.Application.Delivery.Commands.BookDeliverySlot;

public sealed record BookDeliverySlotCommand(int SlotId, int OrderId) : IRequest;
