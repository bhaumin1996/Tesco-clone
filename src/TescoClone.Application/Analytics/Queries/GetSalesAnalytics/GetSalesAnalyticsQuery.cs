using MediatR;
using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Queries.GetSalesAnalytics;

public sealed record GetSalesAnalyticsQuery(DateTime From, DateTime To) : IRequest<SalesAnalyticsDto>;
