using FluentValidation;

namespace TescoClone.Application.Marketplace.Queries.GetSellerListings;

public sealed class GetSellerListingsQueryValidator : AbstractValidator<GetSellerListingsQuery>
{
    public GetSellerListingsQueryValidator()
    {
        RuleFor(x => x.SellerId).GreaterThan(0);
        RuleFor(x => x.PageNumber).GreaterThan(0);
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100);
    }
}
