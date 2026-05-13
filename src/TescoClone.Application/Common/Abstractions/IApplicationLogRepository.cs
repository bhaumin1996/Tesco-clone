using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Abstractions;

public interface IApplicationLogRepository
{
    Task<PaginatedResult<ApplicationLogDto>> GetApplicationLogsAsync(
        string? level,
        string? source,
        string? correlationId,
        DateTime? from,
        DateTime? to,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default);
}
