using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Queries.GetApplicationLogs;
using TescoClone.Application.Common.Queries.GetAuditLogs;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/audit")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminAuditController : ControllerBase
{
    private readonly IMediator _mediator;

    public AdminAuditController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("logs")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetAuditLogs(
        [FromQuery] string? tableName,
        [FromQuery] int? recordId,
        [FromQuery] int? changedBy,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(
            new GetAuditLogsQuery(tableName, recordId, changedBy, from, to, pageNumber, pageSize),
            cancellationToken);
        return Ok(result);
    }

    [HttpGet("application-logs")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetApplicationLogs(
        [FromQuery] string? level,
        [FromQuery] string? source,
        [FromQuery] string? correlationId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(
            new GetApplicationLogsQuery(level, source, correlationId, from, to, pageNumber, pageSize),
            cancellationToken);
        return Ok(result);
    }
}
