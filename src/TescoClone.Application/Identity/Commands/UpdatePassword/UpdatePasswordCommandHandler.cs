using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.UpdatePassword;

public sealed class UpdatePasswordCommandHandler : IRequestHandler<UpdatePasswordCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordService _passwordService;

    public UpdatePasswordCommandHandler(IUserRepository userRepository, IPasswordService passwordService)
    {
        _userRepository = userRepository;
        _passwordService = passwordService;
    }

    public async Task Handle(UpdatePasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.UserId);

        if (!_passwordService.Verify(request.CurrentPassword, user.PasswordHash))
        {
            throw new ForbiddenException("Current password is incorrect.");
        }

        var newPasswordHash = _passwordService.Hash(request.NewPassword);
        await _userRepository.UpdatePasswordAsync(request.UserId, newPasswordHash, cancellationToken);
    }
}
