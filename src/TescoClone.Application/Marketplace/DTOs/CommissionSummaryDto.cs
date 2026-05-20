namespace TescoClone.Application.Marketplace.DTOs;

public sealed record CommissionSummaryDto(
    decimal TotalSales,
    decimal TotalCommission,
    decimal NetEarnings,
    int TransactionCount);
