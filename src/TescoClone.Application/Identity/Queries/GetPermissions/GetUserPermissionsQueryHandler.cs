using MediatR;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Queries.GetPermissions;

public sealed class GetUserPermissionsQueryHandler : IRequestHandler<GetUserPermissionsQuery, IEnumerable<AdminPermissionDto>>
{
    private readonly IAdminUserRepository _adminUserRepository;

    public GetUserPermissionsQueryHandler(IAdminUserRepository adminUserRepository)
    {
        _adminUserRepository = adminUserRepository;
    }

    public async Task<IEnumerable<AdminPermissionDto>> Handle(GetUserPermissionsQuery request, CancellationToken cancellationToken)
    {
        return await _adminUserRepository.GetUserPermissionsAsync(request.UserId, cancellationToken);
    }
}
