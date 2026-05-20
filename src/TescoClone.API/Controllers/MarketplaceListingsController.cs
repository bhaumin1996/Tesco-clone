using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.Commands.CreateListing;
using TescoClone.Application.Marketplace.Commands.DeleteListing;
using TescoClone.Application.Marketplace.Commands.PublishListing;
using TescoClone.Application.Marketplace.Commands.UnpublishListing;
using TescoClone.Application.Marketplace.Commands.UpdateListing;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Application.Marketplace.Queries.GetCommissionSummary;
using TescoClone.Application.Marketplace.Queries.GetListingById;
using TescoClone.Application.Marketplace.Queries.GetSellerListings;
using TescoClone.Domain.Common;

namespace TescoClone.API.Controllers;

// Seller-facing listing management. Requires an approved Seller role JWT.
// All operations are scoped to the authenticated seller's own listings.
[ApiController]
[Route("api/v1/marketplace/listings")]
[Authorize(Policy = AuthorizationPolicies.Seller)]
public sealed class MarketplaceListingsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IMarketplaceRepository _repository;

    public MarketplaceListingsController(
        IMediator mediator,
        ICurrentUser currentUser,
        IMarketplaceRepository repository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _repository = repository;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetListings(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        var result = await _mediator.Send(
            new GetSellerListingsQuery(seller.Id, status, pageNumber, pageSize),
            cancellationToken);

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetListing(int id, CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        var listing = await _mediator.Send(new GetListingByIdQuery(id, seller.Id), cancellationToken);
        return listing is null ? NotFound() : Ok(listing);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateListing(
        [FromBody] CreateListingDto dto,
        CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        var listingId = await _mediator.Send(
            new CreateListingCommand(seller.Id, dto, _currentUser.UserId),
            cancellationToken);

        return CreatedAtAction(nameof(GetListing), new { id = listingId }, new { listingId });
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateListing(
        int id,
        [FromBody] UpdateListingDto dto,
        CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        await _mediator.Send(new UpdateListingCommand(id, seller.Id, dto, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{id:int}/publish")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> PublishListing(int id, CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        await _mediator.Send(new PublishListingCommand(id, seller.Id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{id:int}/unpublish")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UnpublishListing(int id, CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        await _mediator.Send(new UnpublishListingCommand(id, seller.Id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteListing(int id, CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        await _mediator.Send(new DeleteListingCommand(id, seller.Id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpGet("commission-summary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetCommissionSummary(
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate,
        CancellationToken cancellationToken)
    {
        var seller = await ResolveSeller(cancellationToken);
        if (seller is null) return NotFound("Seller account not found.");

        var summary = await _mediator.Send(
            new GetCommissionSummaryQuery(seller.Id, fromDate, toDate),
            cancellationToken);

        return Ok(summary);
    }

    // Resolve the current user's seller record once per request.
    private Task<SellerDto?> ResolveSeller(CancellationToken cancellationToken)
        => _repository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
}
