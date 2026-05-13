using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.ResolveDispute;

public sealed class ResolveDisputeCommandValidator : AbstractValidator<ResolveDisputeCommand>
{
    public ResolveDisputeCommandValidator()
    {
        RuleFor(x => x.DisputeId).GreaterThan(0).WithMessage("DisputeId must be a positive integer.");
        RuleFor(x => x.Resolution).NotEmpty().MaximumLength(1000).WithMessage("Resolution is required and must not exceed 1000 characters.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
