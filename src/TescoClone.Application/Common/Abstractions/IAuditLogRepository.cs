using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Abstractions;

public interface IAuditLogRepository
{
    Task<PaginatedResult<AuditLogDto>> GetAuditLogsAsync(
        string? tableName,
        int? recordId,
        int? changedBy,
        DateTime? from,
        DateTime? to,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default);
}
