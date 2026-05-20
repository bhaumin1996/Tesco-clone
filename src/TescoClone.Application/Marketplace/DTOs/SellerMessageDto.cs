namespace TescoClone.Application.Marketplace.DTOs;

public sealed record MessageThreadSummaryDto(
    int Id,
    int SellerId,
    string Subject,
    bool IsResolved,
    int MessageCount,
    int UnreadCount,
    DateTime CreatedOn,
    DateTime? ModifiedOn);

public sealed record MessageDto(
    int Id,
    int ThreadId,
    int SenderUserId,
    string Body,
    DateTime? ReadAt,
    DateTime CreatedOn);
