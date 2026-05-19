using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.Commands.ProcessRefund;
using TescoClone.Application.Order.Commands.UpdateOrderStatus;
using TescoClone.Application.Order.Queries.GetAllOrders;
using TescoClone.Application.Order.Queries.GetOrderById;
using TescoClone.Domain.Enums;

namespace TescoClone.API.Controllers;

// Admin order management: paginated order list, status transitions, and Stripe refund initiation.
[ApiController]
[Route("api/v1/admin/orders")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminOrdersController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public AdminOrdersController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetOrderById(int id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetOrderByIdQuery(id), cancellationToken);
        return Ok(result);
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetAllOrders(
        [FromQuery] OrderStatus? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetAllOrdersQuery(status, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPut("{id:int}/status")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateOrderStatusCommand(id, request.NewStatus, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{id:int}/refund")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> ProcessRefund(int id, [FromBody] ProcessRefundRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new ProcessRefundCommand(id, request.RefundAmount, request.Reason, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record UpdateOrderStatusRequest(OrderStatus NewStatus);
public sealed record ProcessRefundRequest(decimal RefundAmount, string Reason);
