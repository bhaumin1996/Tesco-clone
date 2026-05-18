using MediatR;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.UpdatePermissions;

public sealed class UpdatePermissionsCommandHandler : IRequestHandler<UpdatePermissionsCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;

    public UpdatePermissionsCommandHandler(IUserRepository userRepository, IAdminUserRepository adminUserRepository)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
    }

    public async Task Handle(UpdatePermissionsCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.TargetUserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.TargetUserId.ToString());

        await _adminUserRepository.SaveUserPermissionsAsync(request.TargetUserId, request.Permissions, request.AdminUserId, cancellationToken);
    }
}
