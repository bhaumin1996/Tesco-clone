using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.DispatchSellerOrder;

public sealed class DispatchSellerOrderCommandValidator : AbstractValidator<DispatchSellerOrderCommand>
{
    public DispatchSellerOrderCommandValidator()
    {
        RuleFor(x => x.SellerOrderId).GreaterThan(0);
        RuleFor(x => x.SellerId).GreaterThan(0);
        RuleFor(x => x.CarrierName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.TrackingNumber).NotEmpty().MaximumLength(100);
        RuleFor(x => x.ModifiedBy).GreaterThan(0);
    }
}
