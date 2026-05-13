using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Commands.AssignRole;
using TescoClone.Application.Identity.Commands.LockUser;
using TescoClone.Application.Identity.Commands.UnlockUser;
using TescoClone.Application.Identity.Queries.GetUsers;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/users")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminUsersController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public AdminUsersController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetUsers(
        [FromQuery] string? search,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetUsersQuery(search, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPost("{userId:int}/lock")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> LockUser(int userId, CancellationToken cancellationToken)
    {
        await _mediator.Send(new LockUserCommand(userId, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{userId:int}/unlock")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UnlockUser(int userId, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UnlockUserCommand(userId, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{userId:int}/roles")]
    [Authorize(Policy = AuthorizationPolicies.SuperAdmin)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AssignRole(int userId, [FromBody] AssignRoleRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new AssignRoleCommand(userId, request.RoleId, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record AssignRoleRequest(int RoleId);
