using MediatR;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.AssignRole;

public sealed class AssignRoleCommandHandler : IRequestHandler<AssignRoleCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;

    public AssignRoleCommandHandler(IUserRepository userRepository, IAdminUserRepository adminUserRepository)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
    }

    public async Task Handle(AssignRoleCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.TargetUserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.TargetUserId.ToString());

        // For admin dashboard role change, we typically want to replace roles
        await _adminUserRepository.ClearRolesAsync(request.TargetUserId, request.AdminUserId, cancellationToken);
        await _adminUserRepository.AssignRoleAsync(request.TargetUserId, request.RoleId, request.AdminUserId, cancellationToken);
    }
}
