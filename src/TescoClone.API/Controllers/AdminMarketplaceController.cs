using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Commands.ApproveSeller;
using TescoClone.Application.Marketplace.Commands.ResolveDispute;
using TescoClone.Application.Marketplace.Commands.ReviewApplication;
using TescoClone.Application.Marketplace.Commands.SuspendSeller;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Application.Marketplace.Queries.GetCommissionTiers;
using TescoClone.Application.Marketplace.Queries.GetSellerApplications;

namespace TescoClone.API.Controllers;

// Admin marketplace management: seller approval/suspension and dispute resolution workflow.
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

    [HttpGet("commission-tiers")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetCommissionTiers(CancellationToken cancellationToken)
    {
        var tiers = await _mediator.Send(new GetCommissionTiersQuery(), cancellationToken);
        return Ok(tiers);
    }

    [HttpGet("applications")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetApplications(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(
            new GetSellerApplicationsQuery(status, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPost("applications/{id:int}/review")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> ReviewApplication(
        int id, [FromBody] ReviewApplicationRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(
            new ReviewApplicationCommand(id, request.Decision, request.ReviewNotes, _currentUser.UserId),
            cancellationToken);
        return NoContent();
    }

    [HttpGet("returns")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetReturns(
        [FromQuery] string? status,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _marketplaceRepository.GetMarketplaceReturnsAsync(status, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("returns/{id:int}/resolve")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> ResolveReturn(
        int id, [FromBody] ResolveReturnRequest request, CancellationToken cancellationToken)
    {
        await _marketplaceRepository.ResolveMarketplaceReturnAsync(
            id, request.Resolution, request.RefundAmount, _currentUser.UserId, cancellationToken);
        return NoContent();
    }

    [HttpGet("payouts")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetPayouts(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var sellers = await _marketplaceRepository.GetSellersAsync(null, 1, 500, cancellationToken);
        var sellerNames = sellers.Items.ToDictionary(seller => seller.Id, seller => seller.BusinessName);
        var payouts = new List<AdminSellerPayoutResponse>();

        foreach (var seller in sellers.Items)
        {
            var sellerPayouts = await _marketplaceRepository.GetSellerPayoutsAsync(
                seller.Id, pageNumber, pageSize, cancellationToken);

            payouts.AddRange(sellerPayouts.Items.Select(payout => new AdminSellerPayoutResponse(
                PayoutId: payout.Id,
                SellerId: payout.SellerId,
                BusinessName: sellerNames.GetValueOrDefault(payout.SellerId, "Marketplace Seller"),
                PeriodStart: payout.PeriodStart,
                PeriodEnd: payout.PeriodEnd,
                GrossSales: payout.GrossSales,
                CommissionDeducted: payout.CommissionDeducted,
                NetPayout: payout.NetPayout,
                Status: payout.Status,
                ProcessedOn: payout.ProcessedOn)));
        }

        return Ok(payouts
            .OrderByDescending(payout => payout.PeriodEnd)
            .ThenBy(payout => payout.BusinessName)
            .ToList());
    }

    [HttpPost("payouts")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> RunPayouts(
        [FromBody] RunPayoutRequest request, CancellationToken cancellationToken)
    {
        var sellers = await _marketplaceRepository.GetSellersAsync("Approved", 1, 500, cancellationToken);
        var results = new List<RunPayoutResultDto>();

        foreach (var seller in sellers.Items)
        {
            var result = await _marketplaceRepository.RunSellerPayoutAsync(
                seller.Id, request.PeriodStart, request.PeriodEnd, _currentUser.UserId, cancellationToken);
            results.Add(result);
        }

        return Ok(results);
    }

    [HttpPost("sellers/{id:int}/payout")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> RunPayout(
        int id, [FromBody] RunPayoutRequest request, CancellationToken cancellationToken)
    {
        var result = await _marketplaceRepository.RunSellerPayoutAsync(
            id, request.PeriodStart, request.PeriodEnd, _currentUser.UserId, cancellationToken);
        return Ok(result);
    }
}

public sealed record SuspendSellerRequest(string Reason);
public sealed record ResolveDisputeRequest(string Resolution);
public sealed record ReviewApplicationRequest(string Decision, string? ReviewNotes);
public sealed record ResolveReturnRequest(string Resolution, decimal? RefundAmount);
public sealed record RunPayoutRequest(DateOnly PeriodStart, DateOnly PeriodEnd);
public sealed record AdminSellerPayoutResponse(
    int PayoutId,
    int SellerId,
    string BusinessName,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    decimal GrossSales,
    decimal CommissionDeducted,
    decimal NetPayout,
    string Status,
    DateTime? ProcessedOn);
