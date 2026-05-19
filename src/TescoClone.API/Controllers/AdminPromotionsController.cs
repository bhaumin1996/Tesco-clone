using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Promotions.Commands.CreatePromotion;
using TescoClone.Application.Promotions.Commands.DeletePromotion;
using TescoClone.Application.Promotions.Commands.UpdatePromotion;
using TescoClone.Application.Promotions.Queries.GetPromotions;

namespace TescoClone.API.Controllers;

// Admin promotion management: CRUD for discount rules with active/inactive filtering.
[ApiController]
[Route("api/v1/admin/promotions")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminPromotionsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public AdminPromotionsController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetPromotions(
        [FromQuery] bool? isActive,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetPromotionsQuery(isActive, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreatePromotion([FromBody] CreatePromotionRequest request, CancellationToken cancellationToken)
    {
        var command = new CreatePromotionCommand(
            request.Name, request.PromotionTypeId, request.DiscountValue,
            request.DiscountPercent, request.MinQuantity, request.StartsAt,
            request.EndsAt, _currentUser.UserId);
        var id = await _mediator.Send(command, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdatePromotion(int id, [FromBody] UpdatePromotionRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdatePromotionCommand(
            id, request.Name, request.DiscountValue, request.DiscountPercent,
            request.MinQuantity, request.StartsAt, request.EndsAt,
            request.IsActive, _currentUser.UserId);
        await _mediator.Send(command, cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeletePromotion(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeletePromotionCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record CreatePromotionRequest(
    string Name, int PromotionTypeId, decimal? DiscountValue, decimal? DiscountPercent,
    int? MinQuantity, DateTime? StartsAt, DateTime? EndsAt);

public sealed record UpdatePromotionRequest(
    string Name, decimal? DiscountValue, decimal? DiscountPercent,
    int? MinQuantity, DateTime? StartsAt, DateTime? EndsAt, bool IsActive);
