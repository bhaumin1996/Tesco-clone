using MediatR;

namespace TescoClone.Application.Promotions.Commands.DeletePromotion;

public sealed record DeletePromotionCommand(int PromotionId, int AdminUserId) : IRequest;
