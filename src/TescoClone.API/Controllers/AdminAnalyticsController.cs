using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Analytics.Queries.GetSalesAnalytics;
using TescoClone.Application.Analytics.Queries.GetTopProducts;
using TescoClone.Application.Analytics.Queries.GetAnalyticsExport;

namespace TescoClone.API.Controllers;

// Admin analytics: sales summary, top products, and CSV export for a given date range.
[ApiController]
[Route("api/v1/admin/analytics")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminAnalyticsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AdminAnalyticsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("sales")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetSales(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        CancellationToken cancellationToken)
    {
        if (from > to)
            return BadRequest("'from' must be before 'to'.");

        var result = await _mediator.Send(new GetSalesAnalyticsQuery(from, to), cancellationToken);
        return Ok(result);
    }

    [HttpGet("top-products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetTopProducts(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        [FromQuery] int top = 10,
        CancellationToken cancellationToken = default)
    {
        if (from > to)
            return BadRequest("'from' must be before 'to'.");

        if (top is < 1 or > 100)
            return BadRequest("'top' must be between 1 and 100.");

        var result = await _mediator.Send(new GetTopProductsQuery(from, to, top), cancellationToken);
        return Ok(result);
    }

    [HttpGet("export")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetExport(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to,
        CancellationToken cancellationToken)
    {
        if (from > to)
            return BadRequest("'from' must be before 'to'.");

        var csvBytes = await _mediator.Send(new GetAnalyticsExportQuery(from, to), cancellationToken);
        var fileName = $"analytics-{from:yyyyMMdd}-to-{to:yyyyMMdd}.csv";
        
        return File(csvBytes, "text/csv", fileName);
    }
}
