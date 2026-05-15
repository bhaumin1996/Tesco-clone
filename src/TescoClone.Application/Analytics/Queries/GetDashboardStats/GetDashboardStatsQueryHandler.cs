using MediatR;
using TescoClone.Application.Analytics.DTOs;
using TescoClone.Application.Analytics.Interfaces;

namespace TescoClone.Application.Analytics.Queries.GetDashboardStats;

public sealed class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardStatsDto>
{
    private readonly IAnalyticsRepository _analyticsRepository;

    public GetDashboardStatsQueryHandler(IAnalyticsRepository analyticsRepository)
    {
        _analyticsRepository = analyticsRepository;
    }

    public Task<DashboardStatsDto> Handle(GetDashboardStatsQuery request, CancellationToken cancellationToken)
        => _analyticsRepository.GetDashboardStatsAsync(cancellationToken);
}
