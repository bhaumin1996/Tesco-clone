using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;

namespace TescoClone.Application.Promotions.Queries.GetPromotions;

public sealed record GetPromotionsQuery(
    bool? IsActive,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<PromotionDto>>;
