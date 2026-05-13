using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Loyalty.Commands.RedeemVoucher;
using TescoClone.Application.Loyalty.Queries.GetClubcard;
using TescoClone.Application.Loyalty.Queries.GetVouchers;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/clubcard")]
[Authorize]
public sealed class ClubcardController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public ClubcardController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetClubcard(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetClubcardQuery(_currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [HttpGet("vouchers")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetVouchers(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetVouchersQuery(_currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [HttpPost("vouchers/redeem")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> RedeemVoucher([FromBody] RedeemVoucherCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}
