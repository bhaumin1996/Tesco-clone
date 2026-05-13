using MediatR;
using TescoClone.Application.Promotions.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Promotions.Commands.DeletePromotion;

public sealed class DeletePromotionCommandHandler : IRequestHandler<DeletePromotionCommand>
{
    private readonly IPromotionRepository _promotionRepository;

    public DeletePromotionCommandHandler(IPromotionRepository promotionRepository)
    {
        _promotionRepository = promotionRepository;
    }

    public async Task Handle(DeletePromotionCommand request, CancellationToken cancellationToken)
    {
        var existing = await _promotionRepository.GetByIdAsync(request.PromotionId, cancellationToken)
            ?? throw new NotFoundException("Promotion", request.PromotionId.ToString());

        await _promotionRepository.SoftDeleteAsync(request.PromotionId, request.AdminUserId, cancellationToken);
    }
}
