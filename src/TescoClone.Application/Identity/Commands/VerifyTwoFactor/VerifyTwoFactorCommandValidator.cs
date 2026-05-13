using FluentValidation;

namespace TescoClone.Application.Identity.Commands.VerifyTwoFactor;

public sealed class VerifyTwoFactorCommandValidator : AbstractValidator<VerifyTwoFactorCommand>
{
    public VerifyTwoFactorCommandValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("UserId must be a positive integer.");

        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("Two-factor code is required.")
            .Length(6).WithMessage("Two-factor code must be 6 characters.");
    }
}
