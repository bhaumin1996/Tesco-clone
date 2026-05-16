using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Addresses.Commands.AddAddress;
using TescoClone.Application.Addresses.Commands.DeleteAddress;
using TescoClone.Application.Addresses.Commands.UpdateAddress;
using TescoClone.Application.Addresses.Queries.GetAddresses;
using TescoClone.Application.Addresses.Interfaces;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.API.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/addresses")]
public sealed class AddressesController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IAddressRepository _addressRepository;

    public AddressesController(IMediator mediator, ICurrentUser currentUser, IAddressRepository addressRepository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _addressRepository = addressRepository;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAddresses(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAddressesQuery(_currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    public async Task<IActionResult> AddAddress([FromBody] AddAddressRequest request, CancellationToken cancellationToken)
    {
        var command = new AddAddressCommand(
            _currentUser.UserId,
            request.AddressLine1,
            request.AddressLine2,
            request.TownCity,
            request.Postcode,
            request.IsDefault);
        await _mediator.Send(command, cancellationToken);
        return StatusCode(StatusCodes.Status201Created);
    }

    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> UpdateAddress(int id, [FromBody] UpdateAddressRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateAddressCommand(
            id,
            _currentUser.UserId,
            request.AddressLine1,
            request.AddressLine2,
            request.TownCity,
            request.Postcode,
            request.IsDefault);
        await _mediator.Send(command, cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteAddress(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteAddressCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("{id}/default")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> SetDefault(int id, CancellationToken cancellationToken)
    {
        await _addressRepository.SetDefaultAsync(id, _currentUser.UserId, cancellationToken);
        return NoContent();
    }

    [HttpPost("import")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> ImportFromOrders(CancellationToken cancellationToken)
    {
        // This will call a repository method to seed addresses from orders
        await _addressRepository.ImportFromOrdersAsync(_currentUser.UserId, cancellationToken);
        return Ok(new { message = "Addresses imported successfully" });
    }
}

public sealed record AddAddressRequest(string AddressLine1, string? AddressLine2, string TownCity, string Postcode, bool IsDefault);
public sealed record UpdateAddressRequest(string AddressLine1, string? AddressLine2, string TownCity, string Postcode, bool IsDefault);
