using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.Commands.ApplyAsSeller;
using TescoClone.Application.Marketplace.Commands.SubmitApplication;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Queries.GetSellerApplication;

namespace TescoClone.API.Controllers;

// Seller self-service onboarding: apply, update draft, submit for review.
[ApiController]
[Route("api/v1/marketplace/sellers")]
[Authorize]
public sealed class MarketplaceOnboardingController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public MarketplaceOnboardingController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet("application")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMyApplication(CancellationToken cancellationToken)
    {
        var application = await _mediator.Send(
            new GetSellerApplicationQuery(_currentUser.UserId), cancellationToken);

        return application is null ? NotFound() : Ok(application);
    }

    [HttpPost("apply")]
    [AllowAnonymous]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Apply([FromBody] ApplyAsSellerDto dto, CancellationToken cancellationToken)
    {
        var applicationId = await _mediator.Send(
            new ApplyAsSellerCommand(_currentUser.UserId, dto), cancellationToken);

        return CreatedAtAction(nameof(GetMyApplication), new { }, new { applicationId });
    }

    [HttpPost("application/{id:int}/submit")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Submit(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new SubmitApplicationCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}
