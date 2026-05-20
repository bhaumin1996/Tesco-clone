namespace TescoClone.Application.Analytics.DTOs;

public sealed record MarketplaceKpisDto(
    decimal Gmv,
    int TotalOrders,
    decimal AverageOrderValue,
    decimal DisputeRate,
    decimal ReturnRate,
    int NewApplicationsCount);
