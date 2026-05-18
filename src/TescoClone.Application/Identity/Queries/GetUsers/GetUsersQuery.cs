using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Queries.GetUsers;

public sealed record GetUsersQuery(
    string? Search,
    string? Role,
    int PageNumber,
    int PageSize) : IRequest<PaginatedResult<AdminUserDto>>;
