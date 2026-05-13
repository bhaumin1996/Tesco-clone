using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Content.Commands.CreatePage;
using TescoClone.Application.Content.Interfaces;
using TescoClone.Application.Content.Queries.GetPages;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/content")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminContentController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IContentRepository _contentRepository;

    public AdminContentController(IMediator mediator, ICurrentUser currentUser, IContentRepository contentRepository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _contentRepository = contentRepository;
    }

    [HttpGet("pages")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetPages(
        [FromQuery] bool? isPublished,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetPagesQuery(isPublished, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPost("pages")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreatePage([FromBody] CreatePageRequest request, CancellationToken cancellationToken)
    {
        var command = new CreatePageCommand(request.Title, request.Slug, request.Content, request.IsPublished, _currentUser.UserId);
        var id = await _mediator.Send(command, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpGet("banners")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetBanners(
        [FromQuery] bool? isActive,
        CancellationToken cancellationToken = default)
    {
        var result = await _contentRepository.GetBannersAsync(isActive, cancellationToken);
        return Ok(result);
    }
}

public sealed record CreatePageRequest(string Title, string Slug, string? Content, bool IsPublished);
