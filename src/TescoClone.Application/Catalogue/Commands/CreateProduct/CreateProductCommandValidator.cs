using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.CreateProduct;

public sealed class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.CategoryId).GreaterThan(0).WithMessage("CategoryId must be a positive integer.");
        RuleFor(x => x.Name).NotEmpty().MaximumLength(300).WithMessage("Name is required and must not exceed 300 characters.");
        RuleFor(x => x.Slug).NotEmpty().MaximumLength(320).Matches("^[a-z0-9-]+$").WithMessage("Slug must be lowercase letters, digits, or hyphens.");
        RuleFor(x => x.BasePrice).GreaterThan(0).WithMessage("BasePrice must be greater than 0.");
        RuleFor(x => x.ClubcardPrice).GreaterThan(0).When(x => x.ClubcardPrice.HasValue).WithMessage("ClubcardPrice must be greater than 0 when provided.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
