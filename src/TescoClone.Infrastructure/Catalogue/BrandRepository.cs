using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

// ADO.NET repository for customer-facing brand list used by the filter panel.
public sealed class BrandRepository : IBrandRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<BrandRepository> _logger;

    public BrandRepository(SqlConnectionFactory connectionFactory, ILogger<BrandRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<BrandDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_GetBrands",
                reader => new BrandDto(
                    SqlHelper.GetValue<int>(reader, "Id"),
                    SqlHelper.GetValue<string>(reader, "Name"),
                    SqlHelper.GetValue<string>(reader, "Slug"),
                    SqlHelper.GetNullableString(reader, "LogoUrl")),
                null,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in BrandRepository.GetAllAsync");
            throw;
        }
    }
}
