using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Models;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class ProductRepository : IProductRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<ProductRepository> _logger;

    public ProductRepository(SqlConnectionFactory connectionFactory, ILogger<ProductRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<ProductDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_GetProductById",
                MapProduct,
                [SqlHelper.Input("@ProductId", id)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByIdAsync for productId: {ProductId}", id);
            throw;
        }
    }

    public async Task<PaginatedResult<ProductDto>> SearchAsync(
        string? searchTerm,
        int? categoryId,
        int? brandId,
        decimal? minPrice,
        decimal? maxPrice,
        bool? inStockOnly,
        string? sortBy,
        string? sortDirection,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var items = await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_SearchProducts",
                reader =>
                {
                    var totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
                    return (Product: MapProduct(reader), TotalCount: totalCount);
                },
                [
                    SqlHelper.Input("@SearchTerm", searchTerm),
                    SqlHelper.InputNullable("@CategoryId", categoryId),
                    SqlHelper.InputNullable("@BrandId", brandId),
                    SqlHelper.InputNullable("@MinPrice", minPrice),
                    SqlHelper.InputNullable("@MaxPrice", maxPrice),
                    SqlHelper.InputNullable("@InStockOnly", inStockOnly),
                    SqlHelper.Input("@SortBy", sortBy ?? "relevance"),
                    SqlHelper.Input("@SortDirection", sortDirection ?? "asc"),
                    SqlHelper.Input("@PageNumber", pageNumber),
                    SqlHelper.Input("@PageSize", pageSize),
                ],
                cancellationToken);

            var totalCount = items.Count > 0 ? items[0].TotalCount : 0;
            return new PaginatedResult<ProductDto>(
                items.Select(x => x.Product).ToList(),
                pageNumber,
                pageSize,
                totalCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in SearchAsync for searchTerm: {SearchTerm}", searchTerm);
            throw;
        }
    }

    public async Task<IReadOnlyList<ProductVariantDto>> GetVariantsAsync(int productId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_GetProductVariants",
                reader => new ProductVariantDto(
                    SqlHelper.GetValue<int>(reader, "Id"),
                    SqlHelper.GetValue<string>(reader, "Sku"),
                    SqlHelper.GetNullableString(reader, "VariantName"),
                    SqlHelper.GetValue<decimal>(reader, "PriceModifier"),
                    SqlHelper.GetValue<int>(reader, "StockQuantity"),
                    SqlHelper.GetValue<bool>(reader, "IsInStock")),
                [SqlHelper.Input("@ProductId", productId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetVariantsAsync for productId: {ProductId}", productId);
            throw;
        }
    }

    private static ProductDto MapProduct(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<int>(reader, "CategoryId"),
            SqlHelper.GetValue<string>(reader, "CategoryName"),
            SqlHelper.GetNullableValue<int>(reader, "BrandId"),
            SqlHelper.GetNullableString(reader, "BrandName"),
            SqlHelper.GetValue<string>(reader, "Name"),
            SqlHelper.GetValue<string>(reader, "Slug"),
            SqlHelper.GetNullableString(reader, "Description"),
            SqlHelper.GetValue<decimal>(reader, "BasePrice"),  // SQL column stays BasePrice
            SqlHelper.GetNullableValue<decimal>(reader, "ClubcardPrice"),
            SqlHelper.GetNullableString(reader, "ImageUrl"),
            SqlHelper.GetValue<bool>(reader, "IsAvailable"),
            SqlHelper.GetValue<bool>(reader, "IsInStock"));
}
