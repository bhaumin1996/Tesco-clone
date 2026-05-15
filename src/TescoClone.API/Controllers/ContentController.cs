using MediatR;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Content.Queries.GetPageBySlug;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public sealed class ContentController : ControllerBase
{
    private readonly IMediator _mediator;

    public ContentController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("pages/{slug}")]
    public async Task<IActionResult> GetPageBySlug(string slug, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetPageBySlugQuery(slug), cancellationToken);
        
        if (result == null)
        {
            return NotFound();
        }

        return Ok(result);
    }
}
