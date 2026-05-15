using MediatR;
using TescoClone.Application.Analytics.DTOs;
using TescoClone.Application.Analytics.Interfaces;

namespace TescoClone.Application.Analytics.Queries.GetSalesAnalytics;

public sealed class GetSalesAnalyticsQueryHandler : IRequestHandler<GetSalesAnalyticsQuery, SalesAnalyticsDto>
{
    private readonly IAnalyticsRepository _analyticsRepository;

    public GetSalesAnalyticsQueryHandler(IAnalyticsRepository analyticsRepository)
    {
        _analyticsRepository = analyticsRepository;
    }

    public Task<SalesAnalyticsDto> Handle(GetSalesAnalyticsQuery request, CancellationToken cancellationToken)
        => _analyticsRepository.GetSalesAnalyticsAsync(request.From, request.To, cancellationToken);
}
