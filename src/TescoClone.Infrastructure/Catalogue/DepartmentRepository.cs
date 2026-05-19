using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

// ADO.NET repository for customer-facing department list and single-department lookup.
public sealed class DepartmentRepository : IDepartmentRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<DepartmentRepository> _logger;

    public DepartmentRepository(SqlConnectionFactory connectionFactory, ILogger<DepartmentRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_GetDepartments",
                MapDepartment,
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetAllAsync");
            throw;
        }
    }

    public async Task<DepartmentDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_GetDepartmentById",
                MapDepartment,
                [SqlHelper.Input("@DepartmentId", id)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByIdAsync for departmentId: {DepartmentId}", id);
            throw;
        }
    }

    private static DepartmentDto MapDepartment(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<string>(reader, "Name"),
            SqlHelper.GetValue<string>(reader, "Slug"),
            SqlHelper.GetNullableString(reader, "ImageUrl"),
            SqlHelper.GetValue<int>(reader, "DisplayOrder"));
}
