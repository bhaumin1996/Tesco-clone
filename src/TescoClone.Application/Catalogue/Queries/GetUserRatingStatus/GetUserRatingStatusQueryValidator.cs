using FluentValidation;

namespace TescoClone.Application.Catalogue.Queries.GetUserRatingStatus;

public sealed class GetUserRatingStatusQueryValidator : AbstractValidator<GetUserRatingStatusQuery>
{
    public GetUserRatingStatusQueryValidator()
    {
        RuleFor(x => x.ProductId).GreaterThan(0);
        RuleFor(x => x.UserId).GreaterThan(0);
    }
}
