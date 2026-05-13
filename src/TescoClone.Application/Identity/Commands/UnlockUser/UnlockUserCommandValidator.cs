using FluentValidation;

namespace TescoClone.Application.Identity.Commands.UnlockUser;

public sealed class UnlockUserCommandValidator : AbstractValidator<UnlockUserCommand>
{
    public UnlockUserCommandValidator()
    {
        RuleFor(x => x.TargetUserId).GreaterThan(0).WithMessage("TargetUserId must be a positive integer.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
