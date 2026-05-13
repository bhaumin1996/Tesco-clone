using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class DepartmentRepository : IDepartmentRepository
{
    private readonly SqlConnectionFactory _connectionFactory;

    public DepartmentRepository(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Catalogue_GetDepartments",
            MapDepartment,
            null,
            cancellationToken);
    }

    public async Task<DepartmentDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Catalogue_GetDepartmentById",
            MapDepartment,
            [SqlHelper.Input("@DepartmentId", id)],
            cancellationToken);
    }

    private static DepartmentDto MapDepartment(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<string>(reader, "Name"),
            SqlHelper.GetValue<string>(reader, "Slug"),
            SqlHelper.GetNullableString(reader, "ImageUrl"),
            SqlHelper.GetValue<int>(reader, "DisplayOrder"));
}
