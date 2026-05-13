using FluentValidation;

namespace TescoClone.Application.Identity.Commands.LockUser;

public sealed class LockUserCommandValidator : AbstractValidator<LockUserCommand>
{
    public LockUserCommandValidator()
    {
        RuleFor(x => x.TargetUserId).GreaterThan(0).WithMessage("TargetUserId must be a positive integer.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
