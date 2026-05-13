using MediatR;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Identity.Queries.GetProfile;

public sealed class GetProfileQueryHandler : IRequestHandler<GetProfileQuery, UserDto>
{
    private readonly IUserRepository _userRepository;

    public GetProfileQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UserDto> Handle(GetProfileQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Identity.User), request.UserId);

        var roles = await _userRepository.GetRolesAsync(user.Id, cancellationToken);
        return new UserDto(user.Id, user.FirstName, user.LastName, user.Email, user.PhoneNumber, roles);
    }
}
