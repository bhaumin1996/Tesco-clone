using MediatR;

namespace TescoClone.Application.Identity.Commands.DeactivateUser;

public sealed record DeactivateUserCommand(int TargetUserId, int AdminUserId) : IRequest;
