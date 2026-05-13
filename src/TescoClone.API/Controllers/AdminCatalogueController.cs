using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Catalogue.Commands.AdjustInventory;
using TescoClone.Application.Catalogue.Commands.CreateProduct;
using TescoClone.Application.Catalogue.Commands.DeleteProduct;
using TescoClone.Application.Catalogue.Commands.UpdateProduct;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Catalogue.Queries.GetProductById;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.API.Controllers;

[ApiController]
[Route("api/v1/admin/catalogue")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminCatalogueController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public AdminCatalogueController(IMediator mediator, ICurrentUser currentUser, IAdminCatalogueRepository adminCatalogueRepository)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    [HttpGet("products")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] string? search,
        [FromQuery] int? categoryId,
        [FromQuery] int? departmentId,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var result = await _adminCatalogueRepository.GetProductsAsync(search, categoryId, departmentId, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost("products")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateProductCommand(
            request.CategoryId, request.BrandId, request.Name, request.Slug,
            request.Description, request.BasePrice, request.ClubcardPrice,
            request.ImageUrl, request.IsAvailable, _currentUser.UserId);
        var id = await _mediator.Send(command, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("products/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateProductCommand(
            id, request.CategoryId, request.BrandId, request.Name,
            request.Description, request.BasePrice, request.ClubcardPrice,
            request.ImageUrl, request.IsAvailable, _currentUser.UserId);
        await _mediator.Send(command, cancellationToken);
        return NoContent();
    }

    [HttpDelete("products/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProduct(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteProductCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("inventory/adjust")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> AdjustInventory([FromBody] AdjustInventoryRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new AdjustInventoryCommand(request.ProductVariantId, request.QuantityDelta, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record CreateProductRequest(
    int CategoryId, int? BrandId, string Name, string Slug, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record UpdateProductRequest(
    int CategoryId, int? BrandId, string Name, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record AdjustInventoryRequest(int ProductVariantId, int QuantityDelta);
