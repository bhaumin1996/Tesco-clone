using FluentValidation;

namespace TescoClone.Application.Identity.Commands.CreateAdminUser;

public sealed class CreateAdminUserCommandValidator : AbstractValidator<CreateAdminUserCommand>
{
    public CreateAdminUserCommandValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(256);
        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128)
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least one digit.");
        RuleFor(x => x.Role)
            .NotEmpty()
            .Must(x => string.Equals(x, "admin", System.StringComparison.OrdinalIgnoreCase) || string.Equals(x, "superadmin", System.StringComparison.OrdinalIgnoreCase))
            .WithMessage("Role must be either 'Admin' or 'SuperAdmin'.");
    }
}
