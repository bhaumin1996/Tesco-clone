using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.Commands.ApproveSeller;
using TescoClone.Application.Marketplace.Commands.ResolveDispute;
using TescoClone.Application.Marketplace.Commands.SuspendSeller;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/marketplace")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminMarketplaceController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IMarketplaceRepository _marketplaceRepository;

    public AdminMarketplaceController(IMediator mediator, ICurrentUser currentUser, IMarketplaceRepository marketplaceRepository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _marketplaceRepository = marketplaceRepository;
    }

    [HttpGet("sellers")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetSellers(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _marketplaceRepository.GetSellersAsync(status, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("sellers/{id:int}/approve")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ApproveSeller(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new ApproveSellerCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("sellers/{id:int}/suspend")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> SuspendSeller(int id, [FromBody] SuspendSellerRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new SuspendSellerCommand(id, request.Reason, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpGet("disputes")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetDisputes(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _marketplaceRepository.GetDisputesAsync(status, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("disputes/{id:int}/resolve")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> ResolveDispute(int id, [FromBody] ResolveDisputeRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new ResolveDisputeCommand(id, request.Resolution, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record SuspendSellerRequest(string Reason);
public sealed record ResolveDisputeRequest(string Resolution);
