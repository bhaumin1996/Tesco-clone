using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetListingById;

public sealed record GetListingByIdQuery(
    int ListingId,
    int? SellerId) : IRequest<ListingDto?>;
