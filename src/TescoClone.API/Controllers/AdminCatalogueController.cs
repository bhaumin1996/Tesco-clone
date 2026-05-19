using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TescoClone.API.Authorization;
using TescoClone.Application.Catalogue.Commands.AdjustInventory;
using TescoClone.Application.Catalogue.Commands.CreateProductVariant;
using TescoClone.Application.Catalogue.Commands.CreateCategory;
using TescoClone.Application.Catalogue.Commands.CreateDepartment;
using TescoClone.Application.Catalogue.Commands.CreateBrand;
using TescoClone.Application.Catalogue.Commands.CreateProduct;
using TescoClone.Application.Catalogue.Commands.DeleteCategory;
using TescoClone.Application.Catalogue.Commands.DeleteProduct;
using TescoClone.Application.Catalogue.Commands.DeleteDepartment;
using TescoClone.Application.Catalogue.Commands.UpdateCategory;
using TescoClone.Application.Catalogue.Commands.UpdateDepartment;
using TescoClone.Application.Catalogue.Commands.UpdateBrand;
using TescoClone.Application.Catalogue.Commands.DeleteBrand;
using TescoClone.Application.Catalogue.Commands.UpdateProduct;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Catalogue.Queries.GetAdminCategories;
using TescoClone.Application.Catalogue.Queries.GetAdminDepartments;
using TescoClone.Application.Catalogue.Queries.GetAdminBrands;
using TescoClone.Application.Catalogue.Queries.GetAdminInventory;
using TescoClone.Application.Catalogue.Queries.GetAdminProducts;
using TescoClone.Application.Catalogue.Queries.GetProductById;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.API.Controllers;

// Admin catalogue management: products, categories, departments, brands, inventory, image upload, and global search.
[ApiController]
[Route("api/v1/admin/catalogue")]
[Authorize(Policy = AuthorizationPolicies.Admin)]
public sealed class AdminCatalogueController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUser _currentUser;
    private readonly IWebHostEnvironment _env;

    public AdminCatalogueController(IMediator mediator, ICurrentUser currentUser, IWebHostEnvironment env)
    {
        _mediator = mediator;
        _currentUser = currentUser;
        _env = env;
    }

    // ── Image Upload ─────────────────────────────────────────────────────────

    private static readonly string[] _allowedMimeTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];
    private static readonly string[] _allowedExtensions = [".jpg", ".jpeg", ".png", ".webp", ".gif"];
    private static readonly string[] _allowedFolders = ["categories", "products", "banners", "brands", "departments"];
    private const long _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

    [HttpPost("/api/v1/admin/images/upload")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UploadImage(IFormFile file, [FromQuery] string folder = "categories", CancellationToken cancellationToken = default)
    {
        if (!_allowedFolders.Contains(folder))
            return BadRequest(new { error = "Invalid folder parameter. Allowed folders: categories, products, banners, brands, departments." });

        if (file is null || file.Length == 0)
            return BadRequest(new { error = "No file provided." });

        if (file.Length > _maxFileSizeBytes)
            return BadRequest(new { error = "File exceeds the 5 MB size limit." });

        if (!_allowedMimeTypes.Contains(file.ContentType.ToLowerInvariant()))
            return BadRequest(new { error = "Only JPEG, PNG, WebP, and GIF images are allowed." });

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_allowedExtensions.Contains(ext))
            return BadRequest(new { error = "Invalid file extension." });

        var uploadDir = Path.Combine(_env.WebRootPath, "assets", "images", folder);
        Directory.CreateDirectory(uploadDir);

        var uniqueName = $"{Guid.NewGuid():N}{ext}";
        var filePath = Path.Combine(uploadDir, uniqueName);

        await using var stream = System.IO.File.Create(filePath);
        await file.CopyToAsync(stream, cancellationToken);

        return Ok(new { path = $"/assets/images/{folder}/{uniqueName}" });
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
        var id = await _mediator.Send(new CreateDepartmentCommand(request.Name, request.Slug, request.ImageUrl, _currentUser.UserId), cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("/api/v1/admin/departments/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateDepartment(int id, [FromBody] UpdateDepartmentRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateDepartmentCommand(id, request.Name, request.Slug, request.ImageUrl, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpDelete("/api/v1/admin/departments/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteDepartment(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteDepartmentCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    // ── Brands ───────────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/brands")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetBrands(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAdminBrandsQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/brands")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateBrand([FromBody] CreateBrandRequest request, CancellationToken cancellationToken)
    {
        var id = await _mediator.Send(new CreateBrandCommand(request.Name, request.Slug, request.LogoUrl, _currentUser.UserId), cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("/api/v1/admin/brands/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateBrand(int id, [FromBody] UpdateBrandRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateBrandCommand(id, request.Name, request.Slug, request.LogoUrl, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpDelete("/api/v1/admin/brands/{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteBrand(int id, CancellationToken cancellationToken)
    {
        await _mediator.Send(new DeleteBrandCommand(id, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    // ── Categories ───────────────────────────────────────────────────────────

    [HttpGet("/api/v1/admin/categories")]
    [HasPermission("Categories", "View")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetCategories(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new GetAdminCategoriesQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/categories")]
    [HasPermission("Categories", "Add")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request, CancellationToken cancellationToken)
    {
        var id = await _mediator.Send(new CreateCategoryCommand(request.Name, request.DepartmentId, request.ImageUrl, _currentUser.UserId), cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { id });
    }

    [HttpPut("/api/v1/admin/categories/{id:int}")]
    [HasPermission("Categories", "Edit")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> UpdateCategory(int id, [FromBody] UpdateCategoryRequest request, CancellationToken cancellationToken)
    {
        await _mediator.Send(new UpdateCategoryCommand(id, request.Name, request.DepartmentId, request.ImageUrl, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPatch("/api/v1/admin/categories/{id:int}/deactivate")]
    [HasPermission("Categories", "Delete")]
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
    [HasPermission("Products", "View")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] string? search,
        [FromQuery] int? categoryId,
        [FromQuery] int? departmentId,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string sortBy = "createdOn",
        [FromQuery] string sortDirection = "desc",
        CancellationToken cancellationToken = default)
    {
        var result = await _mediator.Send(new GetAdminProductsQuery(search, categoryId, departmentId, pageNumber, pageSize, sortBy, sortDirection), cancellationToken);
        return Ok(result);
    }

    [HttpPost("/api/v1/admin/products")]
    [HasPermission("Products", "Add")]
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
    [HasPermission("Products", "Edit")]
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
    [HasPermission("Products", "Delete")]
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
        await _mediator.Send(new AdjustInventoryCommand(request.ProductVariantId, request.Quantity, _currentUser.UserId), cancellationToken);
        return NoContent();
    }

    [HttpPost("/api/v1/admin/inventory")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status422UnprocessableEntity)]
    public async Task<IActionResult> CreateProductVariant([FromBody] CreateProductVariantRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateProductVariantCommand(
            request.ProductId,
            request.Sku,
            request.VariantName,
            request.Barcode,
            request.InitialQuantity,
            request.LowStockThreshold,
            _currentUser.UserId);

        var variantId = await _mediator.Send(command, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, new { variantId });
    }

    [HttpGet("/api/v1/admin/search")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GlobalSearch(
        [FromQuery] string? q,
        [FromServices] IAdminCatalogueRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(q))
        {
            return Ok(new TescoClone.Application.Catalogue.DTOs.AdminGlobalSearchResultDto());
        }

        var result = await repository.GlobalSearchAsync(q.Trim(), cancellationToken);
        return Ok(result);
    }
}

public sealed record CreateProductRequest(
    int CategoryId, int? BrandId, string Name, string Slug, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record UpdateProductRequest(
    int CategoryId, int? BrandId, string Name, string? Description,
    decimal BasePrice, decimal? ClubcardPrice, string? ImageUrl, bool IsAvailable);

public sealed record AdjustInventoryRequest(int ProductVariantId, int Quantity, string? Reason);
public sealed record CreateProductVariantRequest(
    int ProductId,
    string Sku,
    string? VariantName,
    string? Barcode,
    int InitialQuantity,
    int LowStockThreshold);

public sealed record CreateDepartmentRequest(string Name, string Slug, string? ImageUrl);
public sealed record UpdateDepartmentRequest(string Name, string Slug, string? ImageUrl);
public sealed record CreateBrandRequest(string Name, string Slug, string? LogoUrl);
public sealed record UpdateBrandRequest(string Name, string Slug, string? LogoUrl);
public sealed record CreateCategoryRequest(string Name, int DepartmentId, string? ImageUrl);
public sealed record UpdateCategoryRequest(string Name, int DepartmentId, string? ImageUrl);
