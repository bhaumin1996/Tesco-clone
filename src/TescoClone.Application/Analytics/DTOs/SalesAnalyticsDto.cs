namespace TescoClone.Application.Analytics.DTOs;

public sealed record SalesAnalyticsDto(
    DateTime FromDate,
    DateTime ToDate,
    decimal TotalRevenue,
    int TotalOrders,
    decimal AverageOrderValue,
    int NewCustomers,
    int ReturningCustomers,
    IReadOnlyList<DailySalesDto> DailySales);

public sealed record DailySalesDto(
    DateOnly Date,
    int Orders,
    decimal Revenue);
