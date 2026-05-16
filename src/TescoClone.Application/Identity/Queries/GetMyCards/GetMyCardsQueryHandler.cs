using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Queries.GetMyCards;

public sealed class GetMyCardsQueryHandler : IRequestHandler<GetMyCardsQuery, IReadOnlyList<UserCardDto>>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly ICurrentUser _currentUser;

    public GetMyCardsQueryHandler(IPaymentRepository paymentRepository, ICurrentUser currentUser)
    {
        _paymentRepository = paymentRepository;
        _currentUser = currentUser;
    }

    public async Task<IReadOnlyList<UserCardDto>> Handle(GetMyCardsQuery request, CancellationToken cancellationToken)
    {
        var cards = await _paymentRepository.GetCardsByUserIdAsync(_currentUser.UserId, cancellationToken);

        return cards.Select(c => new UserCardDto(
            c.Id,
            c.Brand,
            c.Last4,
            c.ExpiryMonth,
            c.ExpiryYear,
            c.IsDefault,
            c.PaymentMethodId)).ToList();
    }
}
