using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Common.Models;

namespace TescoClone.Infrastructure.Common;

// ADO.NET repository for reading paginated t.tblAuditLog entries in the admin audit viewer.
public sealed class AuditLogRepository : IAuditLogRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AuditLogRepository> _logger;

    public AuditLogRepository(SqlConnectionFactory connectionFactory, ILogger<AuditLogRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<AuditLogDto>> GetAuditLogsAsync(
        string? tableName, int? recordId, int? changedBy,
        DateTime? from, DateTime? to,
        int pageNumber, int pageSize,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetAuditLogs";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@TableName", tableName),
            SqlHelper.InputNullable("@RecordId", recordId),
            SqlHelper.InputNullable("@ChangedBy", changedBy),
            SqlHelper.InputNullable("@From", from),
            SqlHelper.InputNullable("@To", to),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<AuditLogDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapAuditLog(reader));
        }

        return new PaginatedResult<AuditLogDto>(items, pageNumber, pageSize, totalCount);
    }

    private static AuditLogDto MapAuditLog(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<long>(reader, "Id"),
            TableName: SqlHelper.GetValue<string>(reader, "TableName"),
            RecordId: SqlHelper.GetValue<int>(reader, "RecordId"),
            Action: SqlHelper.GetValue<string>(reader, "Action"),
            OldValues: SqlHelper.GetNullableString(reader, "OldValues"),
            NewValues: SqlHelper.GetNullableString(reader, "NewValues"),
            ChangedBy: SqlHelper.GetValue<int>(reader, "ChangedBy"),
            ChangedOn: SqlHelper.GetValue<DateTime>(reader, "ChangedOn"),
            CorrelationId: SqlHelper.GetNullableString(reader, "CorrelationId"));
}
