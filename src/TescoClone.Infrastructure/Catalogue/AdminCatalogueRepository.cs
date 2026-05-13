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

    public async Task<PaginatedResult<AdminProductDto>> GetProductsAsync(
        string? search, int? categoryId, int? departmentId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetProducts";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@Search", search),
            SqlHelper.InputNullable("@CategoryId", categoryId),
            SqlHelper.InputNullable("@DepartmentId", departmentId),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<AdminProductDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapAdminProduct(reader));
        }

        return new PaginatedResult<AdminProductDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<int> CreateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default)
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

    public async Task UpdateProductAsync(AdminProductDto product, int adminId, CancellationToken cancellationToken = default)
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

    public async Task SoftDeleteProductAsync(int productId, int adminId, CancellationToken cancellationToken = default)
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

    public async Task<int> CreateCategoryAsync(string name, int departmentId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Admin_CreateCategory",
            [
                SqlHelper.Input("@Name", name),
                SqlHelper.Input("@DepartmentId", departmentId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task UpdateCategoryAsync(int categoryId, string name, int departmentId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UpdateCategory",
            [
                SqlHelper.Input("@CategoryId", categoryId),
                SqlHelper.Input("@Name", name),
                SqlHelper.Input("@DepartmentId", departmentId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task SoftDeleteCategoryAsync(int categoryId, int adminId, CancellationToken cancellationToken = default)
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

    public async Task<int> CreateDepartmentAsync(string name, int adminId, CancellationToken cancellationToken = default)
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

    public async Task UpdateDepartmentAsync(int departmentId, string name, int adminId, CancellationToken cancellationToken = default)
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

    public async Task AdjustInventoryAsync(int productVariantId, int quantityDelta, int adminId, CancellationToken cancellationToken = default)
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
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));
}
