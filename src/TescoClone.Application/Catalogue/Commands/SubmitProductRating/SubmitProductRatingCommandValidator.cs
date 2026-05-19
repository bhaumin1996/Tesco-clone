using FluentValidation;

namespace TescoClone.Application.Catalogue.Commands.SubmitProductRating;

public sealed class SubmitProductRatingCommandValidator : AbstractValidator<SubmitProductRatingCommand>
{
    public SubmitProductRatingCommandValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0);
        RuleFor(x => x.UserId).GreaterThan(0);
        RuleFor(x => x.Rating).InclusiveBetween(1, 5);
    }
}
