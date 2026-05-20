using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.Commands.ConfirmSellerOrder;
using TescoClone.Application.Marketplace.Commands.DispatchSellerOrder;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Application.Marketplace.Queries.GetSellerOrderById;
using TescoClone.Application.Marketplace.Queries.GetSellerOrders;

namespace TescoClone.API.Controllers;

// Seller-facing order management: list orders, confirm receipt, dispatch with tracking.
[ApiController]
[Route("api/v1/marketplace/orders")]
[Authorize(Policy = AuthorizationPolicies.Seller)]
public sealed class MarketplaceOrdersController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IMarketplaceRepository _marketplaceRepository;

    public MarketplaceOrdersController(
        IMediator mediator,
        ICurrentUser currentUser,
        IMarketplaceRepository marketplaceRepository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _marketplaceRepository = marketplaceRepository;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetOrders(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var seller = await _marketplaceRepository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
        if (seller is null) return NotFound();

        var result = await _mediator.Send(
            new GetSellerOrdersQuery(seller.Id, status, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetOrderById(int id, CancellationToken cancellationToken)
    {
        var seller = await _marketplaceRepository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
        if (seller is null) return NotFound();

        var result = await _mediator.Send(new GetSellerOrderByIdQuery(id, seller.Id), cancellationToken);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpPost("{id:int}/confirm")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Confirm(int id, CancellationToken cancellationToken)
    {
        var seller = await _marketplaceRepository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
        if (seller is null) return NotFound();

        await _mediator.Send(new ConfirmSellerOrderCommand(id, seller.Id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{id:int}/dispatch")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Dispatch(
        int id, [FromBody] DispatchOrderRequest request, CancellationToken cancellationToken)
    {
        var seller = await _marketplaceRepository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
        if (seller is null) return NotFound();

        await _mediator.Send(
            new DispatchSellerOrderCommand(id, seller.Id, request.CarrierName, request.TrackingNumber, _currentUser.UserId),
            cancellationToken);
        return NoContent();
    }
}

public sealed record DispatchOrderRequest(string CarrierName, string TrackingNumber);
