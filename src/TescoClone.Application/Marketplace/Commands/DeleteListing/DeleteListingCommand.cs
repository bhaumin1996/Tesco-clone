using MediatR;

namespace TescoClone.Application.Marketplace.Commands.DeleteListing;

public sealed record DeleteListingCommand(
    int ListingId,
    int SellerId,
    int ModifiedBy) : IRequest;
