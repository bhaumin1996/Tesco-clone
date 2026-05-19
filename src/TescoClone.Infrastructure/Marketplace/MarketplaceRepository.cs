using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Marketplace;

// ADO.NET repository for marketplace seller and dispute management in the admin panel.
public sealed class MarketplaceRepository : IMarketplaceRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<MarketplaceRepository> _logger;

    public MarketplaceRepository(SqlConnectionFactory connectionFactory, ILogger<MarketplaceRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<SellerDto>> GetSellersAsync(
        string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetSellers";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@StatusFilter", statusFilter),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<SellerDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapSeller(reader));
        }

        return new PaginatedResult<SellerDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<SellerDto?> GetSellerByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Admin_GetSellerById",
            MapSeller,
            [SqlHelper.Input("@SellerId", id)],
            cancellationToken);
    }

    public async Task ApproveSellerAsync(int sellerId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ApproveSeller",
            [
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task SuspendSellerAsync(int sellerId, string reason, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SuspendSeller",
            [
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@Reason", reason),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task<PaginatedResult<DisputeDto>> GetDisputesAsync(
        string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetDisputes";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@StatusFilter", statusFilter),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<DisputeDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapDispute(reader));
        }

        return new PaginatedResult<DisputeDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task ResolveDisputeAsync(int disputeId, string resolution, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ResolveDispute",
            [
                SqlHelper.Input("@DisputeId", disputeId),
                SqlHelper.Input("@Resolution", resolution),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    private static SellerDto MapSeller(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            BusinessName: SqlHelper.GetValue<string>(reader, "BusinessName"),
            ContactEmail: SqlHelper.GetValue<string>(reader, "ContactEmail"),
            StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
            CommissionRate: SqlHelper.GetValue<decimal>(reader, "CommissionRate"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));

    private static DisputeDto MapDispute(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            OrderId: SqlHelper.GetValue<int>(reader, "OrderId"),
            SellerId: SqlHelper.GetValue<int>(reader, "SellerId"),
            Subject: SqlHelper.GetValue<string>(reader, "Subject"),
            Description: SqlHelper.GetValue<string>(reader, "Description"),
            StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
            Resolution: SqlHelper.GetNullableString(reader, "Resolution"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ResolvedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ResolvedOn"));
}
