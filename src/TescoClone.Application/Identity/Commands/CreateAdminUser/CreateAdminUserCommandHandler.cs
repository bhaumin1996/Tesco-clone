using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;
using TescoClone.Domain.Identity;

namespace TescoClone.Application.Identity.Commands.CreateAdminUser;

public sealed class CreateAdminUserCommandHandler : IRequestHandler<CreateAdminUserCommand, int>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;
    private readonly IPasswordService _passwordService;

    public CreateAdminUserCommandHandler(
        IUserRepository userRepository,
        IAdminUserRepository adminUserRepository,
        IPasswordService passwordService)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
        _passwordService = passwordService;
    }

    public async Task<int> Handle(CreateAdminUserCommand request, CancellationToken cancellationToken)
    {
        if (await _userRepository.EmailExistsAsync(request.Email, cancellationToken))
            throw new ConflictException("An account with this email address already exists.");

        var passwordHash = _passwordService.Hash(request.Password);
        var user = User.Create(request.FirstName, request.LastName, request.Email, passwordHash, null);

        var userId = await _userRepository.CreateAsync(user, passwordHash, cancellationToken);

        // Assign specified role
        int roleId;
        if (string.Equals(request.Role, "superadmin", StringComparison.OrdinalIgnoreCase))
        {
            roleId = 4;
        }
        else if (string.Equals(request.Role, "admin", StringComparison.OrdinalIgnoreCase))
        {
            roleId = 1;
        }
        else if (string.Equals(request.Role, "customer", StringComparison.OrdinalIgnoreCase))
        {
            roleId = 2;
        }
        else
        {
            throw new ArgumentException("Invalid role specified.");
        }

        // Clear default roles (if any) and assign the requested role
        await _adminUserRepository.ClearRolesAsync(userId, request.AdminUserId, cancellationToken);
        await _adminUserRepository.AssignRoleAsync(userId, roleId, request.AdminUserId, cancellationToken);

        return userId;
    }
}
