using MediatR;

namespace TescoClone.Application.Identity.Commands.LockUser;

public sealed record LockUserCommand(int TargetUserId, int AdminUserId) : IRequest;
