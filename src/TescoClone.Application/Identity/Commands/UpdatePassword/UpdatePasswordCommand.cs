using MediatR;

namespace TescoClone.Application.Identity.Commands.UpdatePassword;

public sealed record UpdatePasswordCommand(
    int UserId,
    string CurrentPassword,
    string NewPassword) : IRequest;
