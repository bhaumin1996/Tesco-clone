using FluentValidation;

namespace TescoClone.Application.Marketplace.Commands.UpdateListing;

public sealed class UpdateListingCommandValidator : AbstractValidator<UpdateListingCommand>
{
    public UpdateListingCommandValidator()
    {
        RuleFor(x => x.ListingId).GreaterThan(0);
        RuleFor(x => x.SellerId).GreaterThan(0);
        RuleFor(x => x.Dto.Title).NotEmpty().MaximumLength(300);
        RuleFor(x => x.Dto.Price).GreaterThan(0);
        RuleFor(x => x.Dto.StockQuantity).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Dto.Description).MaximumLength(10000).When(x => x.Dto.Description != null);
        RuleFor(x => x.Dto.EAN).MaximumLength(50).When(x => x.Dto.EAN != null);
        RuleFor(x => x.Dto.Weight).GreaterThan(0).When(x => x.Dto.Weight.HasValue);
        RuleFor(x => x.Dto.ImageUrl).MaximumLength(500).When(x => x.Dto.ImageUrl != null);
    }
}
