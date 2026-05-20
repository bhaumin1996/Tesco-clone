using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetCommissionTiers;

public sealed record GetCommissionTiersQuery : IRequest<IReadOnlyList<CommissionTierDto>>;
