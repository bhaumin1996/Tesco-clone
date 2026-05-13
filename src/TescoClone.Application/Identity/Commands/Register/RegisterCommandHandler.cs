using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;
using TescoClone.Domain.Identity;

namespace TescoClone.Application.Identity.Commands.Register;

public sealed class RegisterCommandHandler : IRequestHandler<RegisterCommand, AuthResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordService _passwordService;
    private readonly ITokenService _tokenService;

    public RegisterCommandHandler(
        IUserRepository userRepository,
        IPasswordService passwordService,
        ITokenService tokenService)
    {
        _userRepository = userRepository;
        _passwordService = passwordService;
        _tokenService = tokenService;
    }

    public async Task<AuthResultDto> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        if (await _userRepository.EmailExistsAsync(request.Email, cancellationToken))
            throw new ConflictException("An account with this email address already exists.");

        var passwordHash = _passwordService.Hash(request.Password);
        var user = User.Create(request.FirstName, request.LastName, request.Email, passwordHash, request.PhoneNumber);

        var userId = await _userRepository.CreateAsync(user, passwordHash, cancellationToken);
        var roles = new[] { "Customer" };

        var token = _tokenService.GenerateAccessToken(userId, request.Email, roles);
        var refreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenHash = _tokenService.HashRefreshToken(refreshToken);

        await _userRepository.SaveRefreshTokenAsync(userId, refreshTokenHash, token.ExpiresAt, cancellationToken);

        var userDto = new UserDto(userId, request.FirstName, request.LastName, request.Email, request.PhoneNumber, roles);
        return new AuthResultDto(userDto, token with { RefreshToken = refreshToken });
    }
}
