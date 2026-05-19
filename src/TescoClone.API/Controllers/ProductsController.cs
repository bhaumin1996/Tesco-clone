using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.Application.Catalogue.Commands.AddFavourite;
using TescoClone.Application.Catalogue.Commands.RemoveFavourite;
using TescoClone.Application.Catalogue.Commands.SubmitProductRating;
using TescoClone.Application.Catalogue.Queries.GetFavourites;
using TescoClone.Application.Catalogue.Queries.GetFavouriteStatus;
using TescoClone.Application.Catalogue.Queries.GetProductById;
using TescoClone.Application.Catalogue.Queries.GetProductVariants;
using TescoClone.Application.Catalogue.Queries.GetUserRatingStatus;
using TescoClone.Application.Catalogue.Queries.SearchProducts;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.API.Controllers;

// Public catalogue endpoints: full-text product search with filters, product detail, variant list, and user rating submission.
[ApiController]
[Route("api/v1/products")]
public sealed class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;

    public ProductsController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] string? searchTerm,
        [FromQuery] int? categoryId,
        [FromQuery] int? brandId,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] bool? inStockOnly,
        [FromQuery] bool? clubcardOnly,
        [FromQuery] string[]? brands,
        [FromQuery] string[]? dietary,
        [FromQuery] string? sortBy,
        [FromQuery] string? sortDirection,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var query = new SearchProductsQuery(searchTerm, categoryId, brandId, minPrice, maxPrice, inStockOnly, clubcardOnly, brands, dietary, sortBy, sortDirection, pageNumber, pageSize);
        var result = await _mediator.Send(query, cancellationToken);
        return Ok(result);
    }

    [HttpGet("search")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> Search(
        [FromQuery] string? searchTerm,
        [FromQuery] int? categoryId,
        [FromQuery] int? brandId,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] bool? inStockOnly,
        [FromQuery] bool? clubcardOnly,
        [FromQuery] string[]? brands,
        [FromQuery] string[]? dietary,
        [FromQuery] string? sortBy,
        [FromQuery] string? sortDirection,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var query = new SearchProductsQuery(searchTerm, categoryId, brandId, minPrice, maxPrice, inStockOnly, clubcardOnly, brands, dietary, sortBy, sortDirection, pageNumber, pageSize);
        var result = await _mediator.Send(query, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetProductByIdQuery(id), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}/variants")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetVariants(int id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetProductVariantsQuery(id), cancellationToken);
        return Ok(result);
    }

    [Authorize]
    [HttpGet("{id:int}/ratings/my")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyRatingStatus(int id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetUserRatingStatusQuery(id, _currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [Authorize]
    [HttpPost("{id:int}/ratings")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> SubmitRating(int id, [FromBody] SubmitRatingRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new SubmitProductRatingCommand(id, _currentUser.UserId, request.Rating), cancellationToken);
        return NoContent();
    }

    // ── Favourites ──────────────────────────────────────────────────────────────

    [Authorize]
    [HttpGet("favourites")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetFavourites(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetFavouritesQuery(_currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [Authorize]
    [HttpGet("{id:int}/favourites/status")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetFavouriteStatus(int id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetFavouriteStatusQuery(id, _currentUser.UserId), cancellationToken);
        return Ok(result);
    }

    [Authorize]
    [HttpPost("{id:int}/favourites")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> AddFavourite(int id, CancellationToken cancellationToken)
    {
        var favouriteId = await _mediator.Send(new AddFavouriteCommand(id, _currentUser.UserId), cancellationToken);
        return CreatedAtAction(nameof(GetFavouriteStatus), new { id }, new { favouriteId });
    }

    [Authorize]
    [HttpDelete("{id:int}/favourites")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RemoveFavourite(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new RemoveFavouriteCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record SubmitRatingRequest(int Rating);
