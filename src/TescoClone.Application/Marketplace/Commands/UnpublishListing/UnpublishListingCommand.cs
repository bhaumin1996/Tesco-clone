using MediatR;

namespace TescoClone.Application.Marketplace.Commands.UnpublishListing;

public sealed record UnpublishListingCommand(
    int ListingId,
    int SellerId,
    int ModifiedBy) : IRequest;
