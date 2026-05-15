using MediatR;
using TescoClone.Application.Analytics.DTOs;

namespace TescoClone.Application.Analytics.Queries.GetTopProducts;

public sealed record GetTopProductsQuery(DateTime From, DateTime To, int Top = 10) : IRequest<IReadOnlyList<TopProductDto>>;
