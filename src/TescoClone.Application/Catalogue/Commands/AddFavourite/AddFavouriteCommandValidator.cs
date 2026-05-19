using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.AddFavourite;

public sealed class AddFavouriteCommandValidator : AbstractValidator<AddFavouriteCommand>
{
    public AddFavouriteCommandValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0).WithMessage("Product ID must be a positive integer.");
        RuleFor(x => x.UserId).GreaterThan(0).WithMessage("User ID must be a positive integer.");
    }
}
