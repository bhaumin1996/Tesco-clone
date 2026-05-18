using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Commands.UpdatePermissions;

public sealed record UpdatePermissionsCommand(
    int TargetUserId,
    IEnumerable<AdminPermissionDto> Permissions,
    int AdminUserId) : IRequest;
