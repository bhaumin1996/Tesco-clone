using MediatR;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Queries.GetAuditLogs;

public sealed record GetAuditLogsQuery(
    string? TableName,
    int? RecordId,
    int? ChangedBy,
    DateTime? From,
    DateTime? To,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<AuditLogDto>>;
