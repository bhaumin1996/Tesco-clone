using MediatR;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.DeactivateUser;

public sealed class DeactivateUserCommandHandler : IRequestHandler<DeactivateUserCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;

    public DeactivateUserCommandHandler(IUserRepository userRepository, IAdminUserRepository adminUserRepository)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
    }

    public async Task Handle(DeactivateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.TargetUserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.TargetUserId.ToString());

        await _adminUserRepository.DeactivateUserAsync(request.TargetUserId, request.AdminUserId, cancellationToken);
    }
}
