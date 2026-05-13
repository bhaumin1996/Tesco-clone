using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.SuspendSeller;

public sealed class SuspendSellerCommandValidator : AbstractValidator<SuspendSellerCommand>
{
    public SuspendSellerCommandValidator()
    {
        RuleFor(x => x.SellerId).GreaterThan(0).WithMessage("SellerId must be a positive integer.");
        RuleFor(x => x.Reason).NotEmpty().MaximumLength(500).WithMessage("Reason is required and must not exceed 500 characters.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
