using MediatR;

namespace TescoClone.Application.Identity.Commands.RevokeToken;

public sealed record RevokeTokenCommand(int UserId, string RefreshToken) : IRequest;
