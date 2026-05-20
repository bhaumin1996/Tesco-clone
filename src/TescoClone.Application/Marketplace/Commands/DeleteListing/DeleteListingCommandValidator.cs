using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.DeleteListing;

public sealed class DeleteListingCommandValidator : AbstractValidator<DeleteListingCommand>
{
    public DeleteListingCommandValidator()
    {
        RuleFor(x => x.ListingId).GreaterThan(0);
        RuleFor(x => x.SellerId).GreaterThan(0);
    }
}
