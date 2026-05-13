namespace TescoClone.Application.Loyalty.DTOs;

public sealed record ClubcardDto(
    int Id,
    string ClubcardNumber,
    int PointsBalance);
