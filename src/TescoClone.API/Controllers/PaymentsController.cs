using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Identity.Commands.DeleteCard;
using TescoClone.Application.Identity.Queries.GetMyCards;

namespace TescoClone.API.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/payments")]
public sealed class PaymentsController : ControllerBase
{
    private readonly ISender _sender;

    public PaymentsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("cards")]
    public async Task<ActionResult<IReadOnlyList<UserCardDto>>> GetMyCards(CancellationToken cancellationToken)
    {
        var result = await _sender.Send(new GetMyCardsQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpDelete("cards/{id}")]
    public async Task<IActionResult> DeleteCard(int id, CancellationToken cancellationToken)
    {
        await _sender.Send(new DeleteCardCommand(id), cancellationToken);
        return NoContent();
    }
}
