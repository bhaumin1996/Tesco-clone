using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Delivery.Commands.BookDeliverySlot;
using TescoClone.Application.Delivery.Queries.SearchDeliverySlots;
using TescoClone.Domain.Enums;

namespace TescoClone.API.Controllers;

// Delivery slot endpoints: search available slots by postcode/date, and book a slot against an order.
[ApiController]
[Route("api/v1/slots")]
public sealed class SlotsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SlotsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("available")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> GetAvailable(
        [FromQuery] string postcode,
        [FromQuery] DeliveryType? deliveryType,
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate,
        CancellationToken cancellationToken)
    {
        var query = new SearchDeliverySlotsQuery(postcode, deliveryType, fromDate, toDate);
        var result = await _mediator.Send(query, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{slotId:int}/book")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Book(int slotId, [FromBody] BookSlotRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new BookDeliverySlotCommand(slotId, request.OrderId), cancellationToken);
        return NoContent();
    }
}

public sealed record BookSlotRequest(int OrderId);
