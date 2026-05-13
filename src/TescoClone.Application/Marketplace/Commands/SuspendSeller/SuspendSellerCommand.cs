using MediatR;

namespace TescoClone.Application.Marketplace.Commands.SuspendSeller;

public sealed record SuspendSellerCommand(int SellerId, string Reason, int AdminUserId) : IRequest;
