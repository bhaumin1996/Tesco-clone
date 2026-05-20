using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.API.Controllers;

// Seller self-service: ASN, performance, payouts, messaging, delivery options.
[ApiController]
[Route("api/v1/marketplace")]
[Authorize(Policy = AuthorizationPolicies.Seller)]
public sealed class MarketplaceAdvancedController : ControllerBase
{
    private readonly IMarketplaceRepository _repository;
    private readonly ICurrentUser _currentUser;

    public MarketplaceAdvancedController(IMarketplaceRepository repository, ICurrentUser currentUser)
    {
        _repository = repository;
        _currentUser = currentUser;
    }

    private async Task<int?> GetSellerIdAsync(CancellationToken ct)
    {
        var seller = await _repository.GetSellerByUserIdAsync(_currentUser.UserId, ct);
        return seller?.Id;
    }

    // ── ASN ──────────────────────────────────────────────────────────────

    [HttpGet("asn")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetAsns(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var result = await _repository.GetSellerAsnsAsync(sellerId.Value, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("asn")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateAsn([FromBody] CreateAsnDto dto, CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var id = await _repository.CreateAsnAsync(sellerId.Value, dto, _currentUser.UserId, cancellationToken);
        return CreatedAtAction(nameof(GetAsns), new { }, new { id });
    }

    // ── Performance ───────────────────────────────────────────────────────

    [HttpGet("performance")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetPerformance(CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var result = await _repository.GetLatestPerformanceAsync(sellerId.Value, cancellationToken);
        return result is null ? NotFound() : Ok(result);
    }

    // ── Payouts ───────────────────────────────────────────────────────────

    [HttpGet("payouts")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetPayouts(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var result = await _repository.GetSellerPayoutsAsync(sellerId.Value, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    // ── Messaging ─────────────────────────────────────────────────────────

    [HttpGet("messages")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetThreads(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var result = await _repository.GetMessageThreadsAsync(sellerId.Value, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("messages")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateThread([FromBody] CreateThreadRequest request, CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var threadId = await _repository.CreateMessageThreadAsync(sellerId.Value, request.Subject, request.Body, _currentUser.UserId, cancellationToken);
        return CreatedAtAction(nameof(GetMessages), new { threadId }, new { threadId });
    }

    [HttpGet("messages/{threadId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMessages(int threadId, CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var messages = await _repository.GetMessagesByThreadAsync(threadId, sellerId.Value, cancellationToken);
        return Ok(messages);
    }

    [HttpPost("messages/{threadId:int}/reply")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Reply(int threadId, [FromBody] ReplyRequest request, CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var messageId = await _repository.SendMessageAsync(threadId, _currentUser.UserId, request.Body, _currentUser.UserId, cancellationToken);
        return CreatedAtAction(nameof(GetMessages), new { threadId }, new { messageId });
    }

    // ── Delivery options ──────────────────────────────────────────────────

    [HttpGet("delivery-options")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetDeliveryOptions(CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        var result = await _repository.GetSellerDeliveryOptionsAsync(sellerId.Value, cancellationToken);
        return Ok(result);
    }

    [HttpPut("delivery-options")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpsertDeliveryOption(
        [FromBody] UpsertDeliveryOptionDto dto, CancellationToken cancellationToken)
    {
        var sellerId = await GetSellerIdAsync(cancellationToken);
        if (sellerId is null) return NotFound();
        await _repository.UpsertDeliveryOptionAsync(sellerId.Value, dto, _currentUser.UserId, cancellationToken);
        return NoContent();
    }
}

// ── Returns (customer-facing) ────────────────────────────────────────────────

[ApiController]
[Route("api/v1/marketplace/returns")]
[Authorize]
public sealed class MarketplaceReturnsController : ControllerBase
{
    private readonly IMarketplaceRepository _repository;
    private readonly ICurrentUser _currentUser;

    public MarketplaceReturnsController(IMarketplaceRepository repository, ICurrentUser currentUser)
    {
        _repository = repository;
        _currentUser = currentUser;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> RaiseReturn([FromBody] RaiseReturnRequest request, CancellationToken cancellationToken)
    {
        var returnId = await _repository.RaiseReturnAsync(
            request.OrderLineId, _currentUser.UserId, request.ReturnReason, _currentUser.UserId, cancellationToken);
        return CreatedAtAction(null, new { }, new { returnId });
    }
}

// ── Returns (seller-facing) ──────────────────────────────────────────────────

[ApiController]
[Route("api/v1/marketplace/seller-returns")]
[Authorize(Policy = AuthorizationPolicies.Seller)]
public sealed class MarketplaceSellerReturnsController : ControllerBase
{
    private readonly IMarketplaceRepository _repository;
    private readonly ICurrentUser _currentUser;

    public MarketplaceSellerReturnsController(IMarketplaceRepository repository, ICurrentUser currentUser)
    {
        _repository = repository;
        _currentUser = currentUser;
    }

    [HttpPost("{id:int}/respond")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Respond(
        int id, [FromBody] ReturnResponseRequest request, CancellationToken cancellationToken)
    {
        var seller = await _repository.GetSellerByUserIdAsync(_currentUser.UserId, cancellationToken);
        if (seller is null) return NotFound();
        await _repository.RespondToReturnAsync(id, seller.Id, request.Accept, request.SellerResponse, _currentUser.UserId, cancellationToken);
        return NoContent();
    }
}

public sealed record CreateThreadRequest(string Subject, string Body);
public sealed record ReplyRequest(string Body);
public sealed record RaiseReturnRequest(int OrderLineId, string ReturnReason);
public sealed record ReturnResponseRequest(bool Accept, string SellerResponse);
