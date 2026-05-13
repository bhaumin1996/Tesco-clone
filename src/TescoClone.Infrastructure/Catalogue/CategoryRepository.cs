using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class CategoryRepository : ICategoryRepository
{
    private readonly SqlConnectionFactory _connectionFactory;

    public CategoryRepository(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<CategoryDto>> GetAllAsync(int? departmentId = null, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Catalogue_GetCategories",
            MapCategory,
            [SqlHelper.InputNullable("@DepartmentId", departmentId)],
            cancellationToken);
    }

    public async Task<CategoryDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Catalogue_GetCategoryById",
            MapCategory,
            [SqlHelper.Input("@CategoryId", id)],
            cancellationToken);
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
