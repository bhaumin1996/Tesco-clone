using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Common.Models;

namespace TescoClone.Infrastructure.Common;

public sealed class ApplicationLogRepository : IApplicationLogRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<ApplicationLogRepository> _logger;

    public ApplicationLogRepository(SqlConnectionFactory connectionFactory, ILogger<ApplicationLogRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<ApplicationLogDto>> GetApplicationLogsAsync(
        string? level, string? source, string? correlationId,
        DateTime? from, DateTime? to,
        int pageNumber, int pageSize,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetApplicationLogs";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@Level", level),
            SqlHelper.Input("@Source", source),
            SqlHelper.Input("@CorrelationId", correlationId),
            SqlHelper.InputNullable("@From", from),
            SqlHelper.InputNullable("@To", to),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<ApplicationLogDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapLog(reader));
        }

        return new PaginatedResult<ApplicationLogDto>(items, pageNumber, pageSize, totalCount);
    }

    private static ApplicationLogDto MapLog(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<long>(reader, "Id"),
            Level: SqlHelper.GetValue<string>(reader, "Level"),
            Source: SqlHelper.GetValue<string>(reader, "Source"),
            Message: SqlHelper.GetValue<string>(reader, "Message"),
            Exception: SqlHelper.GetNullableString(reader, "Exception"),
            UserId: SqlHelper.GetNullableValue<int>(reader, "UserId"),
            LoggedOn: SqlHelper.GetValue<DateTime>(reader, "LoggedOn"),
            CorrelationId: SqlHelper.GetNullableString(reader, "CorrelationId"));
}
