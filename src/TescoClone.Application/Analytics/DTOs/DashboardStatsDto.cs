namespace TescoClone.Application.Analytics.DTOs;

public sealed record DashboardStatsDto(
    int TotalOrdersToday,
    decimal TotalRevenueToday,
    int NewCustomersToday,
    int PendingOrders,
    int LowStockProducts,
    int OpenDisputes);
