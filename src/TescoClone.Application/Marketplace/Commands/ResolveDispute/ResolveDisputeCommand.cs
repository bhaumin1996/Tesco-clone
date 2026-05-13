using MediatR;

namespace TescoClone.Application.Marketplace.Commands.ResolveDispute;

public sealed record ResolveDisputeCommand(int DisputeId, string Resolution, int AdminUserId) : IRequest;
