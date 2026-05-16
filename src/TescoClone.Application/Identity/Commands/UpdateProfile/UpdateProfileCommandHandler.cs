using MediatR;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Commands.UpdateProfile;

public sealed class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand>
{
    private readonly IUserRepository _userRepository;

    public UpdateProfileCommandHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {
        await _userRepository.UpdateProfileAsync(
            request.UserId,
            request.FirstName,
            request.LastName,
            request.Email,
            request.PhoneNumber,
            cancellationToken);
    }
}
