using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.ConfirmSellerOrder;

public sealed class ConfirmSellerOrderCommandValidator : AbstractValidator<ConfirmSellerOrderCommand>
{
    public ConfirmSellerOrderCommandValidator()
    {
        RuleFor(x => x.SellerOrderId).GreaterThan(0);
        RuleFor(x => x.SellerId).GreaterThan(0);
        RuleFor(x => x.ModifiedBy).GreaterThan(0);
    }
}
