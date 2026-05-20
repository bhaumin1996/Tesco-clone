using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetSellerApplications;

public sealed record GetSellerApplicationsQuery(
    string? StatusFilter,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<SellerApplicationListDto>>;
