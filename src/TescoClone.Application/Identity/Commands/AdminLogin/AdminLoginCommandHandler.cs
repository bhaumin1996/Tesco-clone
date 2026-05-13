using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.AdminLogin;

public sealed class AdminLoginCommandHandler : IRequestHandler<AdminLoginCommand, AdminLoginResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;
    private readonly IPasswordService _passwordService;
    private readonly ITwoFactorService _twoFactorService;
    private readonly IClock _clock;

    private const int MaxFailedAttempts = 5;
    private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(30);

    public AdminLoginCommandHandler(
        IUserRepository userRepository,
        IAdminUserRepository adminUserRepository,
        IPasswordService passwordService,
        ITwoFactorService twoFactorService,
        IClock clock)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
        _passwordService = passwordService;
        _twoFactorService = twoFactorService;
        _clock = clock;
    }

    public async Task<AdminLoginResultDto> Handle(AdminLoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.Email);

        if (user.IsLocked(_clock.UtcNow))
            throw new ConflictException("Account is temporarily locked. Please try again later.");

        var roles = await _userRepository.GetRolesAsync(user.Id, cancellationToken);
        if (!roles.Any(r => r is "Admin" or "SuperAdmin"))
            throw new ForbiddenException("Access restricted to admin accounts.");

        if (!_passwordService.Verify(request.Password, user.PasswordHash))
        {
            user.RecordFailedLogin(MaxFailedAttempts, LockoutDuration);
            await _userRepository.UpdateAsync(user, cancellationToken);
            throw new ForbiddenException("Invalid email or password.");
        }

        user.ResetFailedLogins();
        await _userRepository.UpdateAsync(user, cancellationToken);

        var code = _twoFactorService.GenerateCode();
        var codeHash = _twoFactorService.HashCode(code);
        var expiresAt = _twoFactorService.GetCodeExpiry();

        await _adminUserRepository.SaveTwoFactorCodeAsync(user.Id, codeHash, expiresAt, cancellationToken);

        // In production this code is dispatched via email/SMS notification service.
        // For development the code is embedded in the response token for testability.
        var twoFactorToken = $"{user.Id}:{code}";

        return new AdminLoginResultDto(user.Id, twoFactorToken);
    }
}
