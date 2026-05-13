using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Commands.RefreshToken;

public sealed class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, AuthResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly ITokenService _tokenService;

    public RefreshTokenCommandHandler(IUserRepository userRepository, ITokenService tokenService)
    {
        _userRepository = userRepository;
        _tokenService = tokenService;
    }

    public async Task<AuthResultDto> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.UserId);

        var incomingHash = _tokenService.HashRefreshToken(request.RefreshToken);

        var isValid = await _userRepository.ValidateRefreshTokenAsync(user.Id, incomingHash, cancellationToken);
        if (!isValid)
            throw new ForbiddenException("Refresh token is invalid or has expired.");

        await _userRepository.RevokeRefreshTokenAsync(user.Id, incomingHash, cancellationToken);

        var roles = await _userRepository.GetRolesAsync(user.Id, cancellationToken);
        var token = _tokenService.GenerateAccessToken(user.Id, user.Email, roles);
        var newRefreshToken = _tokenService.GenerateRefreshToken();
        var newRefreshTokenHash = _tokenService.HashRefreshToken(newRefreshToken);

        await _userRepository.SaveRefreshTokenAsync(user.Id, newRefreshTokenHash, token.ExpiresAt, cancellationToken);

        var userDto = new UserDto(user.Id, user.FirstName, user.LastName, user.Email, user.PhoneNumber, roles);
        return new AuthResultDto(userDto, token with { RefreshToken = newRefreshToken });
    }
}
