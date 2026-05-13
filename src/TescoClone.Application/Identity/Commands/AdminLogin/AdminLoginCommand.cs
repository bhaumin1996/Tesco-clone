using MediatR;

namespace TescoClone.Application.Identity.Commands.AdminLogin;

public sealed record AdminLoginCommand(
    string Email,
    string Password) : IRequest<AdminLoginResultDto>;

public sealed record AdminLoginResultDto(int UserId, string TwoFactorToken);
