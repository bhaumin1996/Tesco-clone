using MediatR;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Catalogue.Queries.GetCategories;
using TescoClone.Application.Catalogue.Queries.GetDepartments;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/catalogue")]
public sealed class CatalogueController : ControllerBase
{
    private readonly IMediator _mediator;

    public CatalogueController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("departments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDepartments(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetDepartmentsQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpGet("categories")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetCategories([FromQuery] int? departmentId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetCategoriesQuery(departmentId), cancellationToken);
        return Ok(result);
    }
}
