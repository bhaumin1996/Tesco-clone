using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.ApproveSeller;

public sealed class ApproveSellerCommandValidator : AbstractValidator<ApproveSellerCommand>
{
    public ApproveSellerCommandValidator()
    {
        RuleFor(x => x.SellerId).GreaterThan(0).WithMessage("SellerId must be a positive integer.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
