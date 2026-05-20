using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Commands.RecordCommission;

public sealed record RecordCommissionCommand(
    int SellerId,
    int OrderLineId,
    decimal SaleAmount,
    int? CategoryId,
    int CreatedBy) : IRequest<RecordCommissionResultDto>;
