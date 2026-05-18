using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.Application.Identity.Queries.GetUsers;

public sealed class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, PaginatedResult<AdminUserDto>>
{
    private readonly IAdminUserRepository _adminUserRepository;

    public GetUsersQueryHandler(IAdminUserRepository adminUserRepository)
    {
        _adminUserRepository = adminUserRepository;
    }

    public Task<PaginatedResult<AdminUserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken) =>
        _adminUserRepository.GetUsersAsync(request.Search, request.Role, request.PageNumber, request.PageSize, cancellationToken);
}
