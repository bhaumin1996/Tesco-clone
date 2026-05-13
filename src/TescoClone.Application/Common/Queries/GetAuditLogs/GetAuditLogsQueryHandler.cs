using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Queries.GetAuditLogs;

public sealed class GetAuditLogsQueryHandler : IRequestHandler<GetAuditLogsQuery, PaginatedResult<AuditLogDto>>
{
    private readonly IAuditLogRepository _auditLogRepository;

    public GetAuditLogsQueryHandler(IAuditLogRepository auditLogRepository)
    {
        _auditLogRepository = auditLogRepository;
    }

    public Task<PaginatedResult<AuditLogDto>> Handle(GetAuditLogsQuery request, CancellationToken cancellationToken) =>
        _auditLogRepository.GetAuditLogsAsync(
            request.TableName, request.RecordId, request.ChangedBy,
            request.From, request.To, request.PageNumber, request.PageSize, cancellationToken);
}
