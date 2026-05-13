using FluentValidation;

namespace TescoClone.Application.Content.Commands.CreatePage;

public sealed class CreatePageCommandValidator : AbstractValidator<CreatePageCommand>
{
    public CreatePageCommandValidator()
    {
        RuleFor(x => x.Title).NotEmpty().MaximumLength(300).WithMessage("Title is required and must not exceed 300 characters.");
        RuleFor(x => x.Slug).NotEmpty().MaximumLength(320).Matches("^[a-z0-9-]+$").WithMessage("Slug must be lowercase letters, digits, or hyphens.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
