using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.Commands.AddToCart;
using TescoClone.Application.Order.Commands.ClearCart;
using TescoClone.Application.Order.Commands.RemoveCartItem;
using TescoClone.Application.Order.Commands.UpdateCartItem;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Queries.GetCart;

namespace TescoClone.API.Controllers;

// Manages the authenticated user's server-side persistent cart (add, update, remove, clear).
[ApiController]
[Route("api/v1/cart")]
[Authorize]
public sealed class CartController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public CartController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCart(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetCartQuery(_currentUser.UserId), cancellationToken);
        return Ok(result ?? new CartDto(0, _currentUser.UserId, [], 0, 0, 0, 0, 0, false));
    }

    [HttpPost("items")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> AddItem([FromBody] AddToCartCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpPut("items/{productVariantId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateItem(int productVariantId, [FromBody] UpdateCartItemRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateCartItemCommand(productVariantId, request.Quantity);
        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }

    [HttpDelete("items/{productVariantId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RemoveItem(int productVariantId, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new RemoveCartItemCommand(productVariantId), cancellationToken);
        return Ok(result);
    }

    [HttpDelete]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> ClearCart(CancellationToken cancellationToken)
    {
        await _mediator.Send(new ClearCartCommand(), cancellationToken);
        return NoContent();
    }
}

public sealed record UpdateCartItemRequest(int Quantity);
