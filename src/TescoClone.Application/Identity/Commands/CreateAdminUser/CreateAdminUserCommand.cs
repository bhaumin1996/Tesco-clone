using MediatR;

namespace TescoClone.Application.Identity.Commands.CreateAdminUser;

public sealed record CreateAdminUserCommand(
    string FirstName,
    string LastName,
    string Email,
    string Password,
    string Role,
    int AdminUserId) : IRequest<int>;
