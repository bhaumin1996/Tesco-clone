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
                OpenDisputes: SqlHelper.GetValue<int>(reader, "OpenDisputes"),
                TotalRevenue: SqlHelper.GetValue<decimal>(reader, "TotalRevenue"),
                TotalOrderedCustomers: SqlHelper.GetValue<int>(reader, "TotalOrderedCustomers"));
        }

        return new DashboardStatsDto(0, 0m, 0, 0, 0, 0, 0m, 0);
    }

    public async Task<SalesAnalyticsDto> GetSalesAnalyticsAsync(DateTime from, DateTime to, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Analytics_GetSalesAnalytics";
        command.Parameters.Add(new SqlParameter("@From", System.Data.SqlDbType.DateTime2) { Value = from });
        command.Parameters.Add(new SqlParameter("@To", System.Data.SqlDbType.DateTime2) { Value = to });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        decimal totalRevenue = 0m;
        int totalOrders = 0;
        int newCustomers = 0;
        int returningCustomers = 0;

        if (await reader.ReadAsync(cancellationToken))
        {
            totalRevenue = SqlHelper.GetValue<decimal>(reader, "TotalRevenue");
            totalOrders = SqlHelper.GetValue<int>(reader, "TotalOrders");
            newCustomers = SqlHelper.GetValue<int>(reader, "NewCustomers");
            returningCustomers = SqlHelper.GetValue<int>(reader, "ReturningCustomers");
        }

        var dailySales = new List<DailySalesDto>();
        if (await reader.NextResultAsync(cancellationToken))
        {
            while (await reader.ReadAsync(cancellationToken))
            {
                dailySales.Add(new DailySalesDto(
                    Date: DateOnly.FromDateTime(SqlHelper.GetValue<DateTime>(reader, "Date")),
                    Orders: SqlHelper.GetValue<int>(reader, "Orders"),
                    Revenue: SqlHelper.GetValue<decimal>(reader, "Revenue")));
            }
        }

        var averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0m;

        return new SalesAnalyticsDto(
            FromDate: from,
            ToDate: to,
            TotalRevenue: totalRevenue,
            TotalOrders: totalOrders,
            AverageOrderValue: averageOrderValue,
            NewCustomers: newCustomers,
            ReturningCustomers: returningCustomers,
            DailySales: dailySales);
    }

    public async Task<IReadOnlyList<TopProductDto>> GetTopProductsAsync(DateTime from, DateTime to, int top, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Analytics_GetTopProducts";
        command.Parameters.Add(new SqlParameter("@From", System.Data.SqlDbType.DateTime2) { Value = from });
        command.Parameters.Add(new SqlParameter("@To", System.Data.SqlDbType.DateTime2) { Value = to });
        command.Parameters.Add(new SqlParameter("@Top", System.Data.SqlDbType.Int) { Value = top });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        var results = new List<TopProductDto>();
        while (await reader.ReadAsync(cancellationToken))
        {
            results.Add(new TopProductDto(
                ProductId: SqlHelper.GetValue<int>(reader, "ProductId"),
                ProductName: SqlHelper.GetValue<string>(reader, "ProductName"),
                ImageUrl: SqlHelper.GetNullableString(reader, "ImageUrl"),
                TotalUnitsSold: SqlHelper.GetValue<int>(reader, "TotalUnitsSold"),
                TotalRevenue: SqlHelper.GetValue<decimal>(reader, "TotalRevenue")));
        }

        return results;
    }
}
