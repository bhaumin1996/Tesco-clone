using MediatR;

namespace TescoClone.Application.Marketplace.Commands.PublishListing;

public sealed record PublishListingCommand(
    int ListingId,
    int SellerId,
    int ModifiedBy) : IRequest;
