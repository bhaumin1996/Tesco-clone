using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Commands.UpdateListing;

public sealed record UpdateListingCommand(
    int ListingId,
    int SellerId,
    UpdateListingDto Dto,
    int ModifiedBy) : IRequest;
