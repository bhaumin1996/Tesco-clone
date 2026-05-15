using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Analytics.DTOs;
using TescoClone.Application.Analytics.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Analytics;

public sealed class AnalyticsRepository : IAnalyticsRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AnalyticsRepository> _logger;

    public AnalyticsRepository(SqlConnectionFactory connectionFactory, ILogger<AnalyticsRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<DashboardStatsDto> GetDashboardStatsAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Analytics_GetDashboardStats";

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        if (await reader.ReadAsync(cancellationToken))
        {
            return new DashboardStatsDto(
                TotalOrdersToday: SqlHelper.GetValue<int>(reader, "TotalOrdersToday"),
                TotalRevenueToday: SqlHelper.GetValue<decimal>(reader, "TotalRevenueToday"),
                NewCustomersToday: SqlHelper.GetValue<int>(reader, "NewCustomersToday"),
                PendingOrders: SqlHelper.GetValue<int>(reader, "PendingOrders"),
                LowStockProducts: SqlHelper.GetValue<int>(reader, "LowStockProducts"),
                OpenDisputes: SqlHelper.GetValue<int>(reader, "OpenDisputes"));
        }

        return new DashboardStatsDto(0, 0m, 0, 0, 0, 0);
    }
}
