using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Content.DTOs;

namespace TescoClone.Application.Content.Queries.GetPages;

public sealed record GetPagesQuery(
    bool? IsPublished,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<PageDto>>;
