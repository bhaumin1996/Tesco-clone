using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Interfaces;

public interface IAnalyticsRepository
{
    Task<DashboardStatsDto> GetDashboardStatsAsync(CancellationToken cancellationToken = default);
    Task<SalesAnalyticsDto> GetSalesAnalyticsAsync(DateTime from, DateTime to, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TopProductDto>> GetTopProductsAsync(DateTime from, DateTime to, int top, CancellationToken cancellationToken = default);
}
