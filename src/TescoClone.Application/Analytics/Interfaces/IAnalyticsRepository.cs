using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Interfaces;

public interface IAnalyticsRepository
{
    Task<DashboardStatsDto> GetDashboardStatsAsync(CancellationToken cancellationToken = default);
}
