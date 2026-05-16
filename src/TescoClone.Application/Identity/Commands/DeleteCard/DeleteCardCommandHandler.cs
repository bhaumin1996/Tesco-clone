using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Commands.DeleteCard;

public sealed class DeleteCardCommandHandler : IRequestHandler<DeleteCardCommand>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly ICurrentUser _currentUser;

    public DeleteCardCommandHandler(IPaymentRepository paymentRepository, ICurrentUser currentUser)
    {
        _paymentRepository = paymentRepository;
        _currentUser = currentUser;
    }

    public async Task Handle(DeleteCardCommand request, CancellationToken cancellationToken)
    {
        await _paymentRepository.DeleteCardAsync(_currentUser.UserId, request.CardId, cancellationToken);
    }
}
