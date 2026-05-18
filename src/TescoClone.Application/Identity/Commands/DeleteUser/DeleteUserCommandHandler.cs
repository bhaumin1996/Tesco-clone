using MediatR;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.DeleteUser;

public sealed class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;

    public DeleteUserCommandHandler(IUserRepository userRepository, IAdminUserRepository adminUserRepository)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
    }

    public async Task Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.TargetUserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.TargetUserId.ToString());

        await _adminUserRepository.DeleteUserAsync(request.TargetUserId, request.AdminUserId, cancellationToken);
    }
}
