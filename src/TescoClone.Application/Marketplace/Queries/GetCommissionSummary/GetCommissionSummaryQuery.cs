using MediatR;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Queries.GetCommissionSummary;

public sealed record GetCommissionSummaryQuery(
    int SellerId,
    DateTime? FromDate,
    DateTime? ToDate) : IRequest<CommissionSummaryDto?>;
