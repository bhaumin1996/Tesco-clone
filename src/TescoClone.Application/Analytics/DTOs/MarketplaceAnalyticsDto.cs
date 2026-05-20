using System.Collections.Generic;

namespace TescoClone.Application.Analytics.DTOs;

public sealed record MarketplaceAnalyticsDto(
    MarketplaceKpisDto Kpis,
    IReadOnlyList<TopSellerDto> TopSellers);
