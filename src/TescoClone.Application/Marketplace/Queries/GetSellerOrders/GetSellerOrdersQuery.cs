using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetSellerOrders;

public sealed record GetSellerOrdersQuery(
    int SellerId,
    string? StatusFilter,
    int PageNumber = 1,
    int PageSize = 20) : IRequest<PaginatedResult<SellerOrderSummaryDto>>;
