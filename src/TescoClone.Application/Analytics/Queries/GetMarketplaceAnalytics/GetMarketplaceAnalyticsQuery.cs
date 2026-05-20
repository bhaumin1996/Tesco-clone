using System;
using MediatR;
using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Queries.GetMarketplaceAnalytics;

public sealed record GetMarketplaceAnalyticsQuery(DateTime From, DateTime To) : IRequest<MarketplaceAnalyticsDto>;
