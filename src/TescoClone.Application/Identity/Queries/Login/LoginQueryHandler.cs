using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Queries.Login;

public sealed class LoginQueryHandler : IRequestHandler<LoginQuery, AuthResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordService _passwordService;
    private readonly ITokenService _tokenService;
    private readonly IClock _clock;

    private const int MaxFailedAttempts = 5;
    private static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);

    public LoginQueryHandler(
        IUserRepository userRepository,
        IPasswordService passwordService,
        ITokenService tokenService,
        IClock clock)
    {
        _userRepository = userRepository;
        _passwordService = passwordService;
        _tokenService = tokenService;
        _clock = clock;
    }

    public async Task<AuthResultDto> Handle(LoginQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.Email);

        if (user.IsLocked(_clock.UtcNow))
            throw new ConflictException("Account is temporarily locked. Please try again later.");

        if (!_passwordService.Verify(request.Password, user.PasswordHash))
        {
            user.RecordFailedLogin(MaxFailedAttempts, LockoutDuration);
            await _userRepository.UpdateAsync(user, cancellationToken);
            throw new ForbiddenException("Invalid email or password.");
        }

        user.ResetFailedLogins();
        await _userRepository.UpdateAsync(user, cancellationToken);

        var roles = await _userRepository.GetRolesAsync(user.Id, cancellationToken);
        var token = _tokenService.GenerateAccessToken(user.Id, user.Email, roles);
        var refreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenHash = _tokenService.HashRefreshToken(refreshToken);

        await _userRepository.SaveRefreshTokenAsync(user.Id, refreshTokenHash, token.ExpiresAt, cancellationToken);

        var userDto = new UserDto(user.Id, user.FirstName, user.LastName, user.Email, user.PhoneNumber, roles);
        return new AuthResultDto(userDto, token with { RefreshToken = refreshToken });
    }
}
