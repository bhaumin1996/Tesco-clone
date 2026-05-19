using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Content.Commands.CreatePage;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;
using TescoClone.Application.Content.Queries.GetPages;

namespace TescoClone.API.Controllers;

// Admin CMS management: pages (create, edit, publish, list) and banners (create, edit, toggle active).
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

    [HttpPut("pages/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdatePage(int id, [FromBody] UpdatePageRequest request, CancellationToken cancellationToken)
    {
        var page = await _contentRepository.GetPageByIdAsync(id, cancellationToken);
        if (page is null) return NotFound();
        var updated = page with { Title = request.Title, Slug = request.Slug, Content = request.Content, IsPublished = request.IsPublished };
        await _contentRepository.UpdatePageAsync(updated, _currentUser.UserId, cancellationToken);
        return NoContent();
    }

    [HttpPatch("pages/{id:int}/publish")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> PublishPage(int id, CancellationToken cancellationToken)
    {
        var page = await _contentRepository.GetPageByIdAsync(id, cancellationToken);
        if (page is null) return NotFound();
        var published = page with { IsPublished = true };
        await _contentRepository.UpdatePageAsync(published, _currentUser.UserId, cancellationToken);
        return NoContent();
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
    [HttpGet("banners/{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetBanner(int id, CancellationToken cancellationToken = default)
    {
        var result = await _contentRepository.GetBannerByIdAsync(id, cancellationToken);
        if (result is null) return NotFound();
        return Ok(result);
    }

    [HttpPost("banners")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateBanner([FromBody] CreateBannerRequest request, CancellationToken cancellationToken)
    {
        var banner = new BannerDto(0, request.Title, null, request.ImageUrl, request.LinkUrl, request.DisplayOrder, true, request.StartsAt, request.EndsAt, DateTime.UtcNow, null);
        var id = await _contentRepository.CreateBannerAsync(banner, _currentUser.UserId, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("banners/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdateBanner(int id, [FromBody] UpdateBannerRequest request, CancellationToken cancellationToken)
    {
        var banner = await _contentRepository.GetBannerByIdAsync(id, cancellationToken);
        if (banner is null) return NotFound();
        var updated = banner with { 
            Title = request.Title, 
            ImageUrl = request.ImageUrl, 
            LinkUrl = request.LinkUrl, 
            DisplayOrder = request.DisplayOrder,
            StartsAt = request.StartsAt,
            EndsAt = request.EndsAt
        };
        await _contentRepository.UpdateBannerAsync(updated, _currentUser.UserId, cancellationToken);
        return NoContent();
    }

    [HttpPatch("banners/{id:int}/toggle")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> ToggleBanner(int id, CancellationToken cancellationToken)
    {
        var banner = await _contentRepository.GetBannerByIdAsync(id, cancellationToken);
        if (banner is null) return NotFound();
        var toggled = banner with { IsActive = !banner.IsActive };
        await _contentRepository.UpdateBannerAsync(toggled, _currentUser.UserId, cancellationToken);
        return NoContent();
    }
}

public sealed record CreatePageRequest(string Title, string Slug, string? Content, bool IsPublished);
public sealed record UpdatePageRequest(string Title, string Slug, string? Content, bool IsPublished);
public sealed record CreateBannerRequest(string Title, string? ImageUrl, string? LinkUrl, int DisplayOrder, DateTime? StartsAt = null, DateTime? EndsAt = null);
public sealed record UpdateBannerRequest(string Title, string? ImageUrl, string? LinkUrl, int DisplayOrder, DateTime? StartsAt = null, DateTime? EndsAt = null);
