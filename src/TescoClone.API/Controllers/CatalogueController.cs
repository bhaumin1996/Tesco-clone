using MediatR;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Catalogue.Queries.GetBrands;
using TescoClone.Application.Catalogue.Queries.GetCategories;
using TescoClone.Application.Catalogue.Queries.GetDepartments;

namespace TescoClone.API.Controllers;

// Public catalogue structure endpoints: departments, categories, and brands for navigation menus.
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

    [HttpGet("brands")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBrands(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetBrandsQuery(), cancellationToken);
        return Ok(result);
    }
}
