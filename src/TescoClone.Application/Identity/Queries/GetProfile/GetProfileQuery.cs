using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Queries.GetProfile;

public sealed record GetProfileQuery(int UserId) : IRequest<UserDto>;
