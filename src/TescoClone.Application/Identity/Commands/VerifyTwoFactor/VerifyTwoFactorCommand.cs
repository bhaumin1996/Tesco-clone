using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Commands.VerifyTwoFactor;

public sealed record VerifyTwoFactorCommand(
    int UserId,
    string Code) : IRequest<AuthResultDto>;
