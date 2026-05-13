namespace TescoClone.Application.Common.Models;

public sealed record AuditLogDto(
    long Id,
    string TableName,
    int RecordId,
    string Action,
    string? OldValues,
    string? NewValues,
    int ChangedBy,
    DateTime ChangedOn,
    string? CorrelationId);
