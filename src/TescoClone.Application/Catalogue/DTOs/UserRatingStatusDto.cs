namespace TescoClone.Application.Catalogue.DTOs;

public sealed record UserRatingStatusDto(
    bool CanRate,
    bool HasRated,
    int? ExistingRating);
