using MediatR;

namespace TescoClone.Application.Analytics.Queries.GetAnalyticsExport;

public sealed record GetAnalyticsExportQuery(DateTime From, DateTime To) : IRequest<byte[]>;
