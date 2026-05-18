using MediatR;

namespace TescoClone.Application.Identity.Commands.DeleteUser;

public sealed record DeleteUserCommand(int TargetUserId, int AdminUserId) : IRequest;
