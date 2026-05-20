using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetSellerListings;

public sealed record GetSellerListingsQuery(
    int SellerId,
    string? StatusFilter,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<ListingDto>>;
