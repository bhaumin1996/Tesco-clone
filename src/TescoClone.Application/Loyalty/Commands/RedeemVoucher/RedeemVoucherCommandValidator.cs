using FluentValidation;

namespace TescoClone.Application.Loyalty.Commands.RedeemVoucher;

public sealed class RedeemVoucherCommandValidator : AbstractValidator<RedeemVoucherCommand>
{
    public RedeemVoucherCommandValidator()
    {
        RuleFor(x => x.Code).NotEmpty().MaximumLength(50);
        RuleFor(x => x.OrderId).GreaterThan(0);
    }
}
