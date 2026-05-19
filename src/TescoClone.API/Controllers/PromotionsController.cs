using MediatR;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Promotions.Queries.GetActivePromotions;

namespace TescoClone.API.Controllers;

// Public promotions endpoint: returns currently active promotions for the storefront.
[ApiController]
[Route("api/v1/[controller]")]
public sealed class PromotionsController : ControllerBase
{
    private readonly IMediator _mediator;

    public PromotionsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetActivePromotions(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetActivePromotionsQuery(pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }
}
