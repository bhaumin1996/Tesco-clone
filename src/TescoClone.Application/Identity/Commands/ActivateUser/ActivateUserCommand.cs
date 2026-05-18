using MediatR;

namespace TescoClone.Application.Identity.Commands.ActivateUser;

public sealed record ActivateUserCommand(int TargetUserId, int AdminUserId) : IRequest;
