using MediatR;

namespace TescoClone.Application.Identity.Commands.AssignRole;

public sealed record AssignRoleCommand(int TargetUserId, int RoleId, int AdminUserId) : IRequest;
