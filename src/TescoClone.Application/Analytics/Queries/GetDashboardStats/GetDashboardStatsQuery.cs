using MediatR;
using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Queries.GetDashboardStats;

public sealed record GetDashboardStatsQuery : IRequest<DashboardStatsDto>;
