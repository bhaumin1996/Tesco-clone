using MediatR;

namespace TescoClone.Application.Identity.Queries.GetMyCards;

public sealed record GetMyCardsQuery : IRequest<IReadOnlyList<UserCardDto>>;

public sealed record UserCardDto(
    int Id,
    string Brand,
    string Last4,
    int ExpiryMonth,
    int ExpiryYear,
    bool IsDefault,
    string PaymentMethodId);
