using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Models;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class AdminCatalogueRepository : IAdminCatalogueRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AdminCatalogueRepository> _logger;

    public AdminCatalogueRepository(SqlConnectionFactory connectionFactory, ILogger<AdminCatalogueRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<AdminBrandDto>> GetBrandsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Admin_GetBrands",
                reader => new AdminBrandDto(
                    BrandId: SqlHelper.GetValue<int>(reader, "BrandId"),
                    Name: SqlHelper.GetValue<string>(reader, "Name")),
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetBrandsAsync");
            throw;
        }
    }

    public async Task<IReadOnlyList<AdminDepartmentDto>> GetDepartmentsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Admin_GetDepartments",
                reader => new AdminDepartmentDto(
                    DepartmentId: SqlHelper.GetValue<int>(reader, "DepartmentId"),
                    Name: SqlHelper.GetValue<string>(reader, "Name")),
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetDepartmentsAsync");
            throw;
        }
    }

    public async Task<IReadOnlyList<AdminCategoryDto>> GetCategoriesAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Admin_GetCategories",
                reader => new AdminCategoryDto(
                    CategoryId: SqlHelper.GetValue<int>(reader, "CategoryId"),
                    Name: SqlHelper.GetValue<string>(reader, "Name"),
                    Slug: SqlHelper.GetValue<string>(reader, "Slug"),
                    DepartmentId: SqlHelper.GetValue<int>(reader, "DepartmentId"),
                    DepartmentName: SqlHelper.GetValue<string>(reader, "DepartmentName"),
                    ProductCount: SqlHelper.GetValue<int>(reader, "ProductCount"),
                    IsActive: SqlHelper.GetValue<bool>(reader, "IsActive"),
                    ImageUrl: SqlHelper.GetNullableString(reader, "ImageUrl"),
                    CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetCategoriesAsync");
            throw;
        }
    }

    public async Task<PaginatedResult<AdminProductDto>> GetProductsAsync(
        string? search, int? categoryId, int? departmentId, int pageNumber, int pageSize, string sortBy, string sortDirection, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var items = await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Admin_GetProducts",
                reader =>
                {
                    var totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
                    return (Product: MapAdminProduct(reader), TotalCount: totalCount);
                },
                [
                    SqlHelper.Input("@Search", search),
                    SqlHelper.InputNullable("@CategoryId", categoryId),
                    SqlHelper.InputNullable("@DepartmentId", departmentId),
                    SqlHelper.Input("@PageNumber", pageNumber),
                    SqlHelper.Input("@PageSize", pageSize),
                    SqlHelper.Input("@SortBy", sortBy),
                    SqlHelper.Input("@SortDirection", sortDirection)
                ],
                cancellationToken);

            var totalCount = items.Count > 0 ? items[0].TotalCount : 0;
            return new PaginatedResult<AdminProductDto>(items.Select(x => x.Product).ToList(), pageNumber, pageSize, totalCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetProductsAsync for search: {Search}", search);
            throw;
        }
    }

    public async Task<int> CreateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Admin_CreateProduct",
                [
                    SqlHelper.Input("@CategoryId", product.CategoryId),
                    SqlHelper.InputNullable("@BrandId", product.BrandId),
                    SqlHelper.Input("@Name", product.Name),
                    SqlHelper.Input("@Slug", product.Slug),
                    SqlHelper.Input("@Description", product.Description),
                    SqlHelper.Input("@BasePrice", product.BasePrice),
                    SqlHelper.InputNullable("@ClubcardPrice", product.ClubcardPrice),
                    SqlHelper.Input("@ImageUrl", product.ImageUrl),
                    SqlHelper.Input("@IsAvailable", product.IsAvailable),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateProductAsync for productName: {ProductName}", product.Name);
            throw;
        }
    }

    public async Task UpdateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_UpdateProduct",
                [
                    SqlHelper.Input("@ProductId", product.Id),
                    SqlHelper.Input("@CategoryId", product.CategoryId),
                    SqlHelper.InputNullable("@BrandId", product.BrandId),
                    SqlHelper.Input("@Name", product.Name),
                    SqlHelper.Input("@Description", product.Description),
                    SqlHelper.Input("@BasePrice", product.BasePrice),
                    SqlHelper.InputNullable("@ClubcardPrice", product.ClubcardPrice),
                    SqlHelper.Input("@ImageUrl", product.ImageUrl),
                    SqlHelper.Input("@IsAvailable", product.IsAvailable),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpdateProductAsync for productId: {ProductId}", product.Id);
            throw;
        }
    }

    public async Task SoftDeleteProductAsync(int productId, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_SoftDeleteProduct",
                [
                    SqlHelper.Input("@ProductId", productId),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in SoftDeleteProductAsync for productId: {ProductId}", productId);
            throw;
        }
    }

    public async Task<int> CreateCategoryAsync(string name, string slug, int departmentId, string? imageUrl, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Admin_CreateCategory",
                [
                    SqlHelper.Input("@Name", name),
                    SqlHelper.Input("@Slug", slug),
                    SqlHelper.Input("@DepartmentId", departmentId),
                    SqlHelper.Input("@ImageUrl", (object?)imageUrl ?? DBNull.Value),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateCategoryAsync for categoryName: {CategoryName}", name);
            throw;
        }
    }

    public async Task UpdateCategoryAsync(int categoryId, string name, string slug, int departmentId, string? imageUrl, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_UpdateCategory",
                [
                    SqlHelper.Input("@CategoryId", categoryId),
                    SqlHelper.Input("@Name", name),
                    SqlHelper.Input("@Slug", slug),
                    SqlHelper.Input("@DepartmentId", departmentId),
                    SqlHelper.Input("@ImageUrl", (object?)imageUrl ?? DBNull.Value),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpdateCategoryAsync for categoryId: {CategoryId}", categoryId);
            throw;
        }
    }

    public async Task SoftDeleteCategoryAsync(int categoryId, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_SoftDeleteCategory",
                [
                    SqlHelper.Input("@CategoryId", categoryId),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in SoftDeleteCategoryAsync for categoryId: {CategoryId}", categoryId);
            throw;
        }
    }

    public async Task<int> CreateDepartmentAsync(string name, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Admin_CreateDepartment",
                [
                    SqlHelper.Input("@Name", name),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateDepartmentAsync for departmentName: {DepartmentName}", name);
            throw;
        }
    }

    public async Task UpdateDepartmentAsync(int departmentId, string name, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_UpdateDepartment",
                [
                    SqlHelper.Input("@DepartmentId", departmentId),
                    SqlHelper.Input("@Name", name),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpdateDepartmentAsync for departmentId: {DepartmentId}", departmentId);
            throw;
        }
    }

    public async Task<IReadOnlyList<AdminInventoryDto>> GetInventoryAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Admin_GetInventory",
                reader => new AdminInventoryDto(
                    ProductVariantId: SqlHelper.GetValue<int>(reader, "ProductVariantId"),
                    ProductId: SqlHelper.GetValue<int>(reader, "ProductId"),
                    ProductName: SqlHelper.GetValue<string>(reader, "ProductName"),
                    Sku: SqlHelper.GetValue<string>(reader, "Sku"),
                    StockQuantity: SqlHelper.GetValue<int>(reader, "StockQuantity"),
                    LowStockThreshold: SqlHelper.GetValue<int>(reader, "LowStockThreshold"),
                    IsLowStock: SqlHelper.GetValue<bool>(reader, "IsLowStock"),
                    PlacedAndConfirmedCount: SqlHelper.GetValue<int>(reader, "PlacedAndConfirmedCount"),
                    PendingOrderCount: SqlHelper.GetValue<int>(reader, "PendingOrderCount"),
                    RemainingStock: SqlHelper.GetValue<int>(reader, "RemainingStock"),
                    VariantName: SqlHelper.GetNullableString(reader, "VariantName")),
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetInventoryAsync");
            throw;
        }
    }

    public async Task AdjustInventoryAsync(int productVariantId, int quantityDelta, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Admin_AdjustInventory",
                [
                    SqlHelper.Input("@ProductVariantId", productVariantId),
                    SqlHelper.Input("@QuantityDelta", quantityDelta),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in AdjustInventoryAsync for productVariantId: {ProductVariantId}", productVariantId);
            throw;
        }
    }

    public async Task<int> CreateProductVariantAsync(int productId, string sku, string? variantName, string? barcode, int initialQuantity, int lowStockThreshold, int adminId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Admin_CreateProductVariant",
                [
                    SqlHelper.Input("@ProductId", productId),
                    SqlHelper.Input("@Sku", sku),
                    SqlHelper.Input("@VariantName", variantName),
                    SqlHelper.Input("@Barcode", barcode),
                    SqlHelper.Input("@InitialQuantity", initialQuantity),
                    SqlHelper.Input("@LowStockThreshold", lowStockThreshold),
                    SqlHelper.Input("@AdminId", adminId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateProductVariantAsync for productId: {ProductId}, sku: {Sku}", productId, sku);
            throw;
        }
    }

    private static AdminProductDto MapAdminProduct(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            CategoryId: SqlHelper.GetValue<int>(reader, "CategoryId"),
            CategoryName: SqlHelper.GetValue<string>(reader, "CategoryName"),
            BrandId: SqlHelper.GetNullableValue<int>(reader, "BrandId"),
            BrandName: SqlHelper.GetNullableString(reader, "BrandName"),
            Name: SqlHelper.GetValue<string>(reader, "Name"),
            Slug: SqlHelper.GetValue<string>(reader, "Slug"),
            Description: SqlHelper.GetNullableString(reader, "Description"),
            BasePrice: SqlHelper.GetValue<decimal>(reader, "BasePrice"),
            ClubcardPrice: SqlHelper.GetNullableValue<decimal>(reader, "ClubcardPrice"),
            ImageUrl: SqlHelper.GetNullableString(reader, "ImageUrl"),
            IsAvailable: SqlHelper.GetValue<bool>(reader, "IsAvailable"),
            StockQuantity: SqlHelper.GetValue<int>(reader, "StockQuantity"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"),
            PlacedAndConfirmedCount: SqlHelper.GetValue<int>(reader, "PlacedAndConfirmedCount"),
            PendingOrderCount: SqlHelper.GetValue<int>(reader, "PendingOrderCount"),
            RemainingStock: SqlHelper.GetValue<int>(reader, "RemainingStock"));
}
