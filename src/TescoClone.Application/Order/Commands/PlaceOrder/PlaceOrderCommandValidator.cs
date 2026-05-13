using FluentValidation;

namespace TescoClone.Application.Order.Commands.PlaceOrder;

public sealed class PlaceOrderCommandValidator : AbstractValidator<PlaceOrderCommand>
{
    public PlaceOrderCommandValidator()
    {
        RuleFor(x => x.DeliveryCharge).GreaterThanOrEqualTo(0);
        When(x => x.DeliverySlotId.HasValue, () =>
            RuleFor(x => x.DeliverySlotId).GreaterThan(0));
    }
}
