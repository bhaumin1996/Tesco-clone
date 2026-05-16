using MediatR;

namespace TescoClone.Application.Identity.Commands.UpdateProfile;

public sealed record UpdateProfileCommand(
    int UserId,
    string FirstName,
    string LastName,
    string Email,
    string? PhoneNumber) : IRequest;
