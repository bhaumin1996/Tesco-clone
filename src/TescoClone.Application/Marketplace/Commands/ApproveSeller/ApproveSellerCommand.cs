using MediatR;

namespace TescoClone.Application.Marketplace.Commands.ApproveSeller;

public sealed record ApproveSellerCommand(int SellerId, int AdminUserId) : IRequest;
