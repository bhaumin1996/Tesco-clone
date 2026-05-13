using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Commands.RefreshToken;

public sealed record RefreshTokenCommand(int UserId, string RefreshToken) : IRequest<AuthResultDto>;
