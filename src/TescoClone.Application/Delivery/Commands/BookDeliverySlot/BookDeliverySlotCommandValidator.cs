using FluentValidation;

namespace TescoClone.Application.Delivery.Commands.BookDeliverySlot;

public sealed class BookDeliverySlotCommandValidator : AbstractValidator<BookDeliverySlotCommand>
{
    public BookDeliverySlotCommandValidator()
    {
        RuleFor(x => x.SlotId).GreaterThan(0);
        RuleFor(x => x.OrderId).GreaterThan(0);
    }
}
