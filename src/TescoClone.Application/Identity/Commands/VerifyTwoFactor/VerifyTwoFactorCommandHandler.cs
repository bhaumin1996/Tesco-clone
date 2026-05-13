using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.VerifyTwoFactor;

public sealed class VerifyTwoFactorCommandHandler : IRequestHandler<VerifyTwoFactorCommand, AuthResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminUserRepository _adminUserRepository;
    private readonly ITwoFactorService _twoFactorService;
    private readonly ITokenService _tokenService;

    public VerifyTwoFactorCommandHandler(
        IUserRepository userRepository,
        IAdminUserRepository adminUserRepository,
        ITwoFactorService twoFactorService,
        ITokenService tokenService)
    {
        _userRepository = userRepository;
        _adminUserRepository = adminUserRepository;
        _twoFactorService = twoFactorService;
        _tokenService = tokenService;
    }

    public async Task<AuthResultDto> Handle(VerifyTwoFactorCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.UserId.ToString());

        var codeHash = _twoFactorService.HashCode(request.Code);
        var valid = await _adminUserRepository.ValidateTwoFactorCodeAsync(user.Id, codeHash, cancellationToken);

        if (!valid)
            throw new ForbiddenException("Invalid or expired two-factor code.");

        await _adminUserRepository.ConsumeTwoFactorCodeAsync(user.Id, codeHash, cancellationToken);

        var roles = await _userRepository.GetRolesAsync(user.Id, cancellationToken);
        var token = _tokenService.GenerateAccessToken(user.Id, user.Email, roles);
        var refreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenHash = _tokenService.HashRefreshToken(refreshToken);

        await _userRepository.SaveRefreshTokenAsync(user.Id, refreshTokenHash, token.ExpiresAt, cancellationToken);

        var userDto = new UserDto(user.Id, user.FirstName, user.LastName, user.Email, user.PhoneNumber, roles);
        return new AuthResultDto(userDto, token with { RefreshToken = refreshToken });
    }
}
