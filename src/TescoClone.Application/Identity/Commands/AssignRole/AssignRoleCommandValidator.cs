using FluentValidation;

namespace TescoClone.Application.Identity.Commands.AssignRole;

public sealed class AssignRoleCommandValidator : AbstractValidator<AssignRoleCommand>
{
    public AssignRoleCommandValidator()
    {
        RuleFor(x => x.TargetUserId).GreaterThan(0).WithMessage("TargetUserId must be a positive integer.");
        RuleFor(x => x.RoleId).GreaterThan(0).WithMessage("RoleId must be a positive integer.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
