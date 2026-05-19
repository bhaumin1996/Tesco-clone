using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

// ADO.NET repository for customer-facing category reads, optionally filtered by department.
public sealed class CategoryRepository : ICategoryRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<CategoryRepository> _logger;

    public CategoryRepository(SqlConnectionFactory connectionFactory, ILogger<CategoryRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<CategoryDto>> GetAllAsync(int? departmentId = null, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_GetCategories",
                MapCategory,
                [SqlHelper.InputNullable("@DepartmentId", departmentId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetAllAsync for departmentId: {DepartmentId}", departmentId);
            throw;
        }
    }

    public async Task<CategoryDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_GetCategoryById",
                MapCategory,
                [SqlHelper.Input("@CategoryId", id)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByIdAsync for categoryId: {CategoryId}", id);
            throw;
        }
    }

    private static CategoryDto MapCategory(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<int>(reader, "DepartmentId"),
            SqlHelper.GetNullableValue<int>(reader, "ParentCategoryId"),
            SqlHelper.GetValue<string>(reader, "Name"),
            SqlHelper.GetValue<string>(reader, "Slug"),
            SqlHelper.GetNullableString(reader, "ImageUrl"));
}
