using MediatR;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Queries.GetApplicationLogs;

public sealed record GetApplicationLogsQuery(
    string? Level,
    string? Source,
    string? CorrelationId,
    DateTime? From,
    DateTime? To,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<ApplicationLogDto>>;
