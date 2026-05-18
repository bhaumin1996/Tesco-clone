using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Queries.GetPermissions;

public sealed record GetUserPermissionsQuery(int UserId) : IRequest<IEnumerable<AdminPermissionDto>>;
