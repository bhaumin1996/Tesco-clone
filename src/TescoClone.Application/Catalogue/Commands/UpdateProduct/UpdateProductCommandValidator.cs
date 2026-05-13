using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.UpdateProduct;

public sealed class UpdateProductCommandValidator : AbstractValidator<UpdateProductCommand>
{
    public UpdateProductCommandValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0).WithMessage("ProductId must be a positive integer.");
        RuleFor(x => x.CategoryId).GreaterThan(0).WithMessage("CategoryId must be a positive integer.");
        RuleFor(x => x.Name).NotEmpty().MaximumLength(300).WithMessage("Name is required and must not exceed 300 characters.");
        RuleFor(x => x.BasePrice).GreaterThan(0).WithMessage("BasePrice must be greater than 0.");
        RuleFor(x => x.ClubcardPrice).GreaterThan(0).When(x => x.ClubcardPrice.HasValue).WithMessage("ClubcardPrice must be greater than 0 when provided.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
