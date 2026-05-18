using MediatR;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.ActivateUser;

public sealed class ActivateUserCommandHandler : IRequestHandler<ActivateUserCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;

    public ActivateUserCommandHandler(IUserRepository userRepository, IAdminUserRepository adminUserRepository)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
    }

    public async Task Handle(ActivateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.TargetUserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.TargetUserId.ToString());

        await _adminUserRepository.ActivateUserAsync(request.TargetUserId, request.AdminUserId, cancellationToken);
    }
}
