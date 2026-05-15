using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Analytics.Queries.GetDashboardStats;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/dashboard")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminDashboardController : ControllerBase
{
    private readonly IMediator _mediator;

    public AdminDashboardController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("stats")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetStats(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetDashboardStatsQuery(), cancellationToken);
        return Ok(result);
    }
}
