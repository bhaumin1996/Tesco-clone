using System.Threading;
using System.Threading.Tasks;
using MediatR;
using TescoClone.Application.Analytics.DTOs;
using TescoClone.Application.Analytics.Interfaces;

namespace TescoClone.Application.Analytics.Queries.GetMarketplaceAnalytics;

public sealed class GetMarketplaceAnalyticsQueryHandler : IRequestHandler<GetMarketplaceAnalyticsQuery, MarketplaceAnalyticsDto>
{
    private readonly IAnalyticsRepository _analyticsRepository;

    public GetMarketplaceAnalyticsQueryHandler(IAnalyticsRepository analyticsRepository)
    {
        _analyticsRepository = analyticsRepository;
    }

    public Task<MarketplaceAnalyticsDto> Handle(GetMarketplaceAnalyticsQuery request, CancellationToken cancellationToken)
        => _analyticsRepository.GetMarketplaceAnalyticsAsync(request.From, request.To, cancellationToken);
}
