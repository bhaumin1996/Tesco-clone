using FluentValidation;

namespace TescoClone.Application.Delivery.Queries.SearchDeliverySlots;

public sealed class SearchDeliverySlotsQueryValidator : AbstractValidator<SearchDeliverySlotsQuery>
{
    public SearchDeliverySlotsQueryValidator()
    {
        RuleFor(x => x.Postcode).NotEmpty().MaximumLength(10);
        When(x => x.FromDate.HasValue && x.ToDate.HasValue, () =>
            RuleFor(x => x.ToDate).GreaterThan(x => x.FromDate)
                .WithMessage("ToDate must be after FromDate."));
    }
}
