using MediatR;

namespace TescoClone.Application.Identity.Commands.UnlockUser;

public sealed record UnlockUserCommand(int TargetUserId, int AdminUserId) : IRequest;
