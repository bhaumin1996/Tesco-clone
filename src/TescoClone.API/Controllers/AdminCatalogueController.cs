using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Catalogue.Commands.AdjustInventory;
using TescoClone.Application.Catalogue.Commands.CreateCategory;
using TescoClone.Application.Catalogue.Commands.CreateDepartment;
using TescoClone.Application.Catalogue.Commands.CreateProduct;
using TescoClone.Application.Catalogue.Commands.DeleteCategory;
using TescoClone.Application.Catalogue.Commands.DeleteProduct;
using TescoClone.Application.Catalogue.Commands.UpdateCategory;
using TescoClone.Application.Catalogue.Commands.UpdateDepartment;
using TescoClone.Application.Catalogue.Commands.UpdateProduct;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Catalogue.Queries.GetAdminCategories;
using TescoClone.Application.Catalogue.Queries.GetAdminDepartments;
using TescoClone.Application.Catalogue.Queries.GetAdminInventory;
using TescoClone.Application.Catalogue.Queries.GetAdminProducts;
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

    public AdminCatalogueController(IMediator mediator, ICurrentUser currentUser)
    {
        _mediator = mediator;
        _currentUser = currentUser;
    }

    // ── Departments ──────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/departments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetDepartments(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAdminDepartmentsQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/departments")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateDepartment([FromBody] CreateDepartmentRequest request, CancellationToken cancellationToken)
    {
        var id = await _mediator.Send(new CreateDepartmentCommand(request.Name, _currentUser.UserId), cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("/api/v1/admin/departments/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateDepartment(int id, [FromBody] UpdateDepartmentRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateDepartmentCommand(id, request.Name, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    // ── Categories ───────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/categories")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetCategories(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAdminCategoriesQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/categories")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request, CancellationToken cancellationToken)
    {
        var id = await _mediator.Send(new CreateCategoryCommand(request.Name, request.DepartmentId, _currentUser.UserId), cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("/api/v1/admin/categories/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateCategoryCommand(id, request.Name, request.DepartmentId, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPatch("/api/v1/admin/categories/{id:int}/deactivate")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeactivateCategory(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteCategoryCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    // ── Products ─────────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/products")]
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
        var result = await _mediator.Send(new GetAdminProductsQuery(search, categoryId, departmentId, pageNumber, pageSize), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/products")]
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

    [HttpPut("/api/v1/admin/products/{id:int}")]
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

    [HttpDelete("/api/v1/admin/products/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProduct(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteProductCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    // ── Inventory ─────────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/inventory")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetInventory(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAdminInventoryQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/inventory/adjust")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> AdjustInventory([FromBody] AdjustInventoryRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new AdjustInventoryCommand(request.ProductId, request.Quantity, _currentUser.UserId), cancellationToken);
        return NoContent();
    }
}

public sealed record CreateProductRequest(
    int CategoryId, int? BrandId, string Name, string Slug, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record UpdateProductRequest(
    int CategoryId, int? BrandId, string Name, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record AdjustInventoryRequest(int ProductId, int Quantity, string? Reason);

public sealed record CreateDepartmentRequest(string Name);
public sealed record UpdateDepartmentRequest(string Name);
public sealed record CreateCategoryRequest(string Name, int DepartmentId);
public sealed record UpdateCategoryRequest(string Name, int DepartmentId);
