using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.DeleteProduct;

public sealed class DeleteProductCommandValidator : AbstractValidator<DeleteProductCommand>
{
    public DeleteProductCommandValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0).WithMessage("ProductId must be a positive integer.");
        RuleFor(x => x.AdminUserId).GreaterThan(0).WithMessage("AdminUserId must be a positive integer.");
    }
}
