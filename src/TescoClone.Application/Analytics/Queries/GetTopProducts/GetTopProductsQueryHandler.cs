using MediatR;
using TescoClone.Application.Analytics.DTOs;
using TescoClone.Application.Analytics.Interfaces;

namespace TescoClone.Application.Analytics.Queries.GetTopProducts;

public sealed class GetTopProductsQueryHandler : IRequestHandler<GetTopProductsQuery, IReadOnlyList<TopProductDto>>
{
    private readonly IAnalyticsRepository _analyticsRepository;

    public GetTopProductsQueryHandler(IAnalyticsRepository analyticsRepository)
    {
        _analyticsRepository = analyticsRepository;
    }

    public Task<IReadOnlyList<TopProductDto>> Handle(GetTopProductsQuery request, CancellationToken cancellationToken)
        => _analyticsRepository.GetTopProductsAsync(request.From, request.To, request.Top, cancellationToken);
}
