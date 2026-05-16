using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;

namespace TescoClone.Application.Promotions.Queries.GetActivePromotions;

public sealed record GetActivePromotionsQuery(int PageNumber, int PageSize) : IRequest<PaginatedResult<PromotionDto>>;
