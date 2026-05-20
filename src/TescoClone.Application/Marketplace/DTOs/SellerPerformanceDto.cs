namespace TescoClone.Application.Marketplace.DTOs;

public sealed record SellerPerformanceDto(
    int Id,
    int SellerId,
    DateOnly ScoreDate,
    decimal? OnTimeDeliveryRate,
    decimal? ReturnRate,
    decimal? CancellationRate,
    decimal? AverageRating,
    decimal? OverallScore,
    bool BelowThreshold,
    DateTime CreatedOn);
