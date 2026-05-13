namespace TescoClone.Application.Common.Models;

public sealed record ApplicationLogDto(
    long Id,
    string Level,
    string Source,
    string Message,
    string? Exception,
    int? UserId,
    DateTime LoggedOn,
    string? CorrelationId);
