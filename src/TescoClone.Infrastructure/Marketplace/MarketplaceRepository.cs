using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Marketplace;

public sealed class MarketplaceRepository : IMarketplaceRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<MarketplaceRepository> _logger;

    public MarketplaceRepository(SqlConnectionFactory connectionFactory, ILogger<MarketplaceRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    // ── Seller management ──────────────────────────────────────────────

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

    public async Task<SellerDto?> GetSellerByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_GetSellerByUserId",
            MapSeller,
            [SqlHelper.Input("@UserId", userId)],
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

    // ── Dispute management ─────────────────────────────────────────────

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

    // ── Listing management ─────────────────────────────────────────────

    public async Task<PaginatedResult<ListingDto>> GetSellerListingsAsync(
        int sellerId, string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Marketplace_GetSellerListings";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@SellerId", sellerId),
            SqlHelper.Input("@StatusFilter", statusFilter),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<ListingDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapListing(reader));
        }

        return new PaginatedResult<ListingDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<ListingDto?> GetListingByIdAsync(int listingId, int? sellerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_GetListingById",
            MapListing,
            [
                SqlHelper.Input("@ListingId", listingId),
                SqlHelper.InputNullable("@SellerId", sellerId)
            ],
            cancellationToken);
    }

    public async Task<int> CreateListingAsync(int sellerId, CreateListingDto dto, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_CreateListing",
            [
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.InputNullable("@ProductId", dto.ProductId),
                SqlHelper.Input("@Title", dto.Title),
                SqlHelper.Input("@Description", (object?)dto.Description ?? DBNull.Value),
                SqlHelper.Input("@Slug", (object?)dto.Slug ?? DBNull.Value),
                SqlHelper.Input("@ImageUrl", (object?)dto.ImageUrl ?? DBNull.Value),
                SqlHelper.Input("@Price", dto.Price),
                SqlHelper.Input("@StockQuantity", dto.StockQuantity),
                SqlHelper.Input("@EAN", (object?)dto.EAN ?? DBNull.Value),
                SqlHelper.InputNullable("@Weight", dto.Weight),
                SqlHelper.InputNullable("@CategoryId", dto.CategoryId),
                SqlHelper.Input("@CreatedBy", createdBy)
            ],
            cancellationToken);
    }

    public async Task UpdateListingAsync(int listingId, int sellerId, UpdateListingDto dto, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_UpdateListing",
            [
                SqlHelper.Input("@ListingId", listingId),
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@Title", dto.Title),
                SqlHelper.Input("@Description", (object?)dto.Description ?? DBNull.Value),
                SqlHelper.Input("@Slug", (object?)dto.Slug ?? DBNull.Value),
                SqlHelper.Input("@ImageUrl", (object?)dto.ImageUrl ?? DBNull.Value),
                SqlHelper.Input("@Price", dto.Price),
                SqlHelper.Input("@StockQuantity", dto.StockQuantity),
                SqlHelper.Input("@EAN", (object?)dto.EAN ?? DBNull.Value),
                SqlHelper.InputNullable("@Weight", dto.Weight),
                SqlHelper.InputNullable("@CategoryId", dto.CategoryId),
                SqlHelper.Input("@ModifiedBy", modifiedBy)
            ],
            cancellationToken);
    }

    public async Task PublishListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_PublishListing",
            [
                SqlHelper.Input("@ListingId", listingId),
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@ModifiedBy", modifiedBy)
            ],
            cancellationToken);
    }

    public async Task UnpublishListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_UnpublishListing",
            [
                SqlHelper.Input("@ListingId", listingId),
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@ModifiedBy", modifiedBy)
            ],
            cancellationToken);
    }

    public async Task SoftDeleteListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_SoftDeleteListing",
            [
                SqlHelper.Input("@ListingId", listingId),
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.Input("@ModifiedBy", modifiedBy)
            ],
            cancellationToken);
    }

    // ── Seller onboarding ──────────────────────────────────────────────

    public async Task<int> ApplyAsSellerAsync(int userId, ApplyAsSellerDto dto, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_ApplyAsSeller",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@BusinessName", dto.BusinessName),
                SqlHelper.Input("@BusinessEmail", dto.BusinessEmail),
                SqlHelper.Input("@Phone", (object?)dto.Phone ?? DBNull.Value),
                SqlHelper.Input("@Description", (object?)dto.Description ?? DBNull.Value),
                SqlHelper.Input("@RegistrationNumber", (object?)dto.RegistrationNumber ?? DBNull.Value),
                SqlHelper.Input("@VatNumber", (object?)dto.VatNumber ?? DBNull.Value),
                SqlHelper.Input("@BankDetailsRef", (object?)dto.BankDetailsRef ?? DBNull.Value),
                SqlHelper.Input("@CategoryIds", (object?)dto.CategoryIds ?? DBNull.Value),
                SqlHelper.Input("@TsAndCsAccepted", dto.TsAndCsAccepted),
                SqlHelper.Input("@Website", (object?)dto.Website ?? DBNull.Value)
            ],
            cancellationToken);
    }

    public async Task SubmitApplicationAsync(int applicationId, int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_SubmitApplication",
            [
                SqlHelper.Input("@ApplicationId", applicationId),
                SqlHelper.Input("@UserId", userId)
            ],
            cancellationToken);
    }

    public async Task<SellerApplicationDto?> GetApplicationByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_GetApplicationByUserId",
            reader => new SellerApplicationDto(
                Id: SqlHelper.GetValue<int>(reader, "Id"),
                UserId: SqlHelper.GetValue<int>(reader, "UserId"),
                BusinessName: SqlHelper.GetValue<string>(reader, "BusinessName"),
                BusinessEmail: SqlHelper.GetValue<string>(reader, "BusinessEmail"),
                Phone: SqlHelper.GetNullableString(reader, "Phone"),
                Description: SqlHelper.GetNullableString(reader, "Description"),
                RegistrationNumber: SqlHelper.GetNullableString(reader, "RegistrationNumber"),
                VatNumber: SqlHelper.GetNullableString(reader, "VatNumber"),
                CategoryIds: SqlHelper.GetNullableString(reader, "CategoryIds"),
                TsAndCsAccepted: SqlHelper.GetValue<bool>(reader, "TsAndCsAccepted"),
                StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
                ReviewNotes: SqlHelper.GetNullableString(reader, "ReviewNotes"),
                ReviewedBy: SqlHelper.GetNullableValue<int>(reader, "ReviewedBy"),
                ReviewedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ReviewedOn"),
                CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"),
                Website: SqlHelper.GetNullableString(reader, "Website")),
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);
    }

    public async Task<PaginatedResult<SellerApplicationListDto>> GetSellerApplicationsAsync(
        string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetSellerApplications";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@StatusFilter", statusFilter),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<SellerApplicationListDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(new SellerApplicationListDto(
                Id: SqlHelper.GetValue<int>(reader, "Id"),
                UserId: SqlHelper.GetValue<int>(reader, "UserId"),
                BusinessName: SqlHelper.GetValue<string>(reader, "BusinessName"),
                BusinessEmail: SqlHelper.GetValue<string>(reader, "BusinessEmail"),
                Phone: SqlHelper.GetNullableString(reader, "Phone"),
                StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
                TsAndCsAccepted: SqlHelper.GetValue<bool>(reader, "TsAndCsAccepted"),
                ReviewNotes: SqlHelper.GetNullableString(reader, "ReviewNotes"),
                ReviewedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ReviewedOn"),
                CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"),
                Website: SqlHelper.GetNullableString(reader, "Website"),
                RegistrationNumber: SqlHelper.GetNullableString(reader, "RegistrationNumber"),
                VatNumber: SqlHelper.GetNullableString(reader, "VatNumber"),
                Description: SqlHelper.GetNullableString(reader, "Description"),
                BankDetailsRef: SqlHelper.GetNullableString(reader, "BankDetailsRef"),
                CategoryIds: SqlHelper.GetNullableString(reader, "CategoryIds")));
        }

        return new PaginatedResult<SellerApplicationListDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task ReviewApplicationAsync(int applicationId, string decision, string? reviewNotes, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ReviewApplication",
            [
                SqlHelper.Input("@ApplicationId", applicationId),
                SqlHelper.Input("@Decision", decision),
                SqlHelper.Input("@ReviewNotes", (object?)reviewNotes ?? DBNull.Value),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task<string?> CheckSellerUniqueAsync(
        string businessName, string email, string phone, string? website, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_CheckSellerUnique",
            reader => SqlHelper.GetNullableString(reader, "ConflictType"),
            [
                SqlHelper.Input("@BusinessName", businessName),
                SqlHelper.Input("@Email", email),
                SqlHelper.Input("@Phone", phone),
                SqlHelper.Input("@Website", (object?)website ?? DBNull.Value)
            ],
            cancellationToken);
    }

    // ── Commission engine ──────────────────────────────────────────────

    public async Task<RecordCommissionResultDto> RecordCommissionAsync(
        int sellerId, int orderLineId, decimal saleAmount, int? categoryId, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Marketplace_RecordCommission";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@SellerId", sellerId),
            SqlHelper.Input("@OrderLineId", orderLineId),
            SqlHelper.Input("@SaleAmount", saleAmount),
            SqlHelper.InputNullable("@CategoryId", categoryId),
            SqlHelper.Input("@CreatedBy", createdBy)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new RecordCommissionResultDto(
                CommissionId: SqlHelper.GetValue<long>(reader, "CommissionId"),
                CommissionAmount: SqlHelper.GetValue<decimal>(reader, "CommissionAmount"));
        }

        return new RecordCommissionResultDto(0, 0);
    }

    public async Task<CommissionSummaryDto?> GetSellerCommissionSummaryAsync(
        int sellerId, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_GetSellerCommissionSummary",
            reader => new CommissionSummaryDto(
                TotalSales: SqlHelper.GetValue<decimal>(reader, "TotalSales"),
                TotalCommission: SqlHelper.GetValue<decimal>(reader, "TotalCommission"),
                NetEarnings: SqlHelper.GetValue<decimal>(reader, "NetEarnings"),
                TransactionCount: SqlHelper.GetValue<int>(reader, "TransactionCount")),
            [
                SqlHelper.Input("@SellerId", sellerId),
                SqlHelper.InputNullable("@FromDate", fromDate),
                SqlHelper.InputNullable("@ToDate", toDate)
            ],
            cancellationToken);
    }

    public async Task<IReadOnlyList<CommissionTierDto>> GetCommissionTiersAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetCommissionTiers",
            reader => new CommissionTierDto(
                Id: SqlHelper.GetValue<int>(reader, "Id"),
                Name: SqlHelper.GetValue<string>(reader, "Name"),
                CategoryId: SqlHelper.GetNullableValue<int>(reader, "CategoryId"),
                CategoryName: SqlHelper.GetNullableString(reader, "CategoryName"),
                Rate: SqlHelper.GetValue<decimal>(reader, "Rate"),
                IsDefault: SqlHelper.GetValue<bool>(reader, "IsDefault"),
                CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn")),
            null,
            cancellationToken);
    }

    // ── Private mappers ────────────────────────────────────────────────

    private static SellerDto MapSeller(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            BusinessName: SqlHelper.GetNullableString(reader, "BusinessName") ?? string.Empty,
            ContactEmail: SqlHelper.GetNullableString(reader, "ContactEmail") ?? string.Empty,
            StatusName: SqlHelper.GetNullableString(reader, "StatusName") ?? "Pending",
            CommissionRate: SqlHelper.GetValue<decimal>(reader, "CommissionRate"),
            RegistrationNumber: SqlHelper.GetNullableString(reader, "RegistrationNumber"),
            VatNumber: SqlHelper.GetNullableString(reader, "VatNumber"),
            Phone: SqlHelper.GetNullableString(reader, "Phone"),
            Description: SqlHelper.GetNullableString(reader, "Description"),
            BankDetailsRef: SqlHelper.GetNullableString(reader, "BankDetailsRef"),
            CommissionTierId: SqlHelper.GetNullableValue<int>(reader, "CommissionTierId"),
            ApprovedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ApprovedOn"),
            SuspendedOn: SqlHelper.GetNullableValue<DateTime>(reader, "SuspendedOn"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"),
            Website: SqlHelper.GetNullableString(reader, "Website"),
            TotalListings: SqlHelper.GetValue<int>(reader, "TotalListings"));

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
            ResolvedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ResolvedOn"),
            SellerName: SqlHelper.GetValue<string>(reader, "SellerName"),
            Reason: SqlHelper.GetValue<string>(reader, "Reason"));

    private static ListingDto MapListing(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            SellerId: SqlHelper.GetValue<int>(reader, "SellerId"),
            ProductId: SqlHelper.GetNullableValue<int>(reader, "ProductId"),
            Title: SqlHelper.GetValue<string>(reader, "Title"),
            Description: SqlHelper.GetNullableString(reader, "Description"),
            Slug: SqlHelper.GetNullableString(reader, "Slug"),
            ImageUrl: SqlHelper.GetNullableString(reader, "ImageUrl"),
            Price: SqlHelper.GetValue<decimal>(reader, "Price"),
            StockQuantity: SqlHelper.GetValue<int>(reader, "StockQuantity"),
            EAN: SqlHelper.GetNullableString(reader, "EAN"),
            Weight: SqlHelper.GetNullableValue<decimal>(reader, "Weight"),
            CategoryId: SqlHelper.GetNullableValue<int>(reader, "CategoryId"),
            StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
            IsActive: SqlHelper.GetValue<bool>(reader, "IsActive"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));

    // ── Seller order fulfillment ───────────────────────────────────────────

    public async Task CreateSellerOrdersForOrderAsync(int orderId, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_CreateSellerOrdersForOrder",
            [
                SqlHelper.Input("@OrderId",   orderId),
                SqlHelper.Input("@CreatedBy", createdBy),
            ],
            cancellationToken);
    }

    public async Task<PaginatedResult<SellerOrderSummaryDto>> GetSellerOrdersAsync(
        int sellerId, string? statusFilter, int pageNumber, int pageSize,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var items = await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetSellerOrders",
            reader =>
            {
                var total = SqlHelper.GetValue<int>(reader, "TotalCount");
                return (Summary: MapSellerOrderSummary(reader), Total: total);
            },
            [
                SqlHelper.Input("@SellerId",     sellerId),
                SqlHelper.Input("@StatusFilter", statusFilter),
                SqlHelper.Input("@PageNumber",   pageNumber),
                SqlHelper.Input("@PageSize",     pageSize),
            ],
            cancellationToken);

        int totalCount = items.Count > 0 ? items[0].Total : 0;
        return new PaginatedResult<SellerOrderSummaryDto>(
            items.Select(x => x.Summary).ToList(), pageNumber, pageSize, totalCount);
    }

    public async Task<SellerOrderDto?> GetSellerOrderByIdAsync(
        int sellerOrderId, int sellerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Marketplace_GetSellerOrderById";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@SellerOrderId", sellerOrderId),
            SqlHelper.Input("@SellerId",      sellerId),
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        // First result set: header
        SellerOrderDto? header = null;
        if (await reader.ReadAsync(cancellationToken))
        {
            header = new SellerOrderDto(
                Id:              SqlHelper.GetValue<int>(reader, "Id"),
                OrderId:         SqlHelper.GetValue<int>(reader, "OrderId"),
                OrderNumber:     SqlHelper.GetValue<string>(reader, "OrderNumber"),
                StatusName:      SqlHelper.GetValue<string>(reader, "StatusName"),
                CarrierName:     SqlHelper.GetNullableString(reader, "CarrierName"),
                TrackingNumber:  SqlHelper.GetNullableString(reader, "TrackingNumber"),
                ConfirmedOn:     SqlHelper.GetNullableValue<DateTime>(reader, "ConfirmedOn"),
                DispatchedOn:    SqlHelper.GetNullableValue<DateTime>(reader, "DispatchedOn"),
                OrderPlacedOn:   SqlHelper.GetValue<DateTime>(reader, "OrderPlacedOn"),
                DeliveryAddress: SqlHelper.GetNullableString(reader, "DeliveryAddress"),
                Items:           []);
        }

        if (header is null) return null;

        // Second result set: lines
        await reader.NextResultAsync(cancellationToken);
        var lines = new List<SellerOrderLineDto>();
        while (await reader.ReadAsync(cancellationToken))
        {
            lines.Add(new SellerOrderLineDto(
                Id:          SqlHelper.GetValue<int>(reader, "Id"),
                ProductId:   SqlHelper.GetValue<int>(reader, "ProductId"),
                ProductName: SqlHelper.GetValue<string>(reader, "ProductName"),
                ImageUrl:    SqlHelper.GetNullableString(reader, "ImageUrl"),
                Price:       SqlHelper.GetValue<decimal>(reader, "Price"),
                Quantity:    SqlHelper.GetValue<int>(reader, "Quantity"),
                LineTotal:   SqlHelper.GetValue<decimal>(reader, "LineTotal"),
                ListingId:   SqlHelper.GetNullableValue<int>(reader, "ListingId"),
                SellerId:    SqlHelper.GetNullableValue<int>(reader, "SellerId")));
        }

        return header with { Items = lines };
    }

    public async Task ConfirmSellerOrderAsync(
        int sellerOrderId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_ConfirmSellerOrder",
            [
                SqlHelper.Input("@SellerOrderId", sellerOrderId),
                SqlHelper.Input("@SellerId",      sellerId),
                SqlHelper.Input("@ModifiedBy",    modifiedBy),
            ],
            cancellationToken);
    }

    public async Task DispatchSellerOrderAsync(
        int sellerOrderId, int sellerId, string carrierName, string trackingNumber, int modifiedBy,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_DispatchSellerOrder",
            [
                SqlHelper.Input("@SellerOrderId",  sellerOrderId),
                SqlHelper.Input("@SellerId",       sellerId),
                SqlHelper.Input("@CarrierName",    carrierName),
                SqlHelper.Input("@TrackingNumber", trackingNumber),
                SqlHelper.Input("@ModifiedBy",     modifiedBy),
            ],
            cancellationToken);
    }

    private static SellerOrderSummaryDto MapSellerOrderSummary(SqlDataReader reader) =>
        new(
            Id:            SqlHelper.GetValue<int>(reader, "Id"),
            OrderId:       SqlHelper.GetValue<int>(reader, "OrderId"),
            OrderNumber:   SqlHelper.GetValue<string>(reader, "OrderNumber"),
            StatusName:    SqlHelper.GetValue<string>(reader, "StatusName"),
            CarrierName:   SqlHelper.GetNullableString(reader, "CarrierName"),
            TrackingNumber: SqlHelper.GetNullableString(reader, "TrackingNumber"),
            ConfirmedOn:   SqlHelper.GetNullableValue<DateTime>(reader, "ConfirmedOn"),
            DispatchedOn:  SqlHelper.GetNullableValue<DateTime>(reader, "DispatchedOn"),
            LineCount:     SqlHelper.GetValue<int>(reader, "LineCount"),
            SellerTotal:   SqlHelper.GetValue<decimal>(reader, "SellerTotal"),
            OrderPlacedOn: SqlHelper.GetValue<DateTime>(reader, "OrderPlacedOn"));

    // ── ASN ───────────────────────────────────────────────────────────────

    public async Task<int> CreateAsnAsync(
        int sellerId, CreateAsnDto dto, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var result = await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_CreateASN",
            [
                SqlHelper.Input("@SellerId",            sellerId),
                SqlHelper.Input("@ExpectedArrivalDate", dto.ExpectedArrivalDate.ToDateTime(TimeOnly.MinValue)),
                SqlHelper.Input("@SkusJson",            dto.SkusJson),
                SqlHelper.Input("@Notes",               dto.Notes),
                SqlHelper.Input("@CreatedBy",           createdBy),
            ],
            cancellationToken);
        return result;
    }

    public async Task<PaginatedResult<SellerAsnDto>> GetSellerAsnsAsync(
        int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var items = await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetSellerASNs",
            reader =>
            {
                var total = SqlHelper.GetValue<int>(reader, "TotalCount");
                return (Asn: new SellerAsnDto(
                    Id:                  SqlHelper.GetValue<int>(reader, "Id"),
                    SellerId:            SqlHelper.GetValue<int>(reader, "SellerId"),
                    ExpectedArrivalDate: DateOnly.FromDateTime(SqlHelper.GetValue<DateTime>(reader, "ExpectedArrivalDate")),
                    SkusJson:            SqlHelper.GetValue<string>(reader, "SkusJson"),
                    Status:              SqlHelper.GetValue<string>(reader, "Status"),
                    Notes:               SqlHelper.GetNullableString(reader, "Notes"),
                    CreatedOn:           SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
                Total: total);
            },
            [
                SqlHelper.Input("@SellerId",   sellerId),
                SqlHelper.Input("@PageNumber", pageNumber),
                SqlHelper.Input("@PageSize",   pageSize),
            ],
            cancellationToken);

        int totalCount = items.Count > 0 ? items[0].Total : 0;
        return new PaginatedResult<SellerAsnDto>(items.Select(x => x.Asn).ToList(), pageNumber, pageSize, totalCount);
    }

    // ── Returns ───────────────────────────────────────────────────────────

    public async Task<int> RaiseReturnAsync(
        int orderLineId, int userId, string returnReason, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_RaiseReturn",
            [
                SqlHelper.Input("@OrderLineId",  orderLineId),
                SqlHelper.Input("@UserId",       userId),
                SqlHelper.Input("@ReturnReason", returnReason),
                SqlHelper.Input("@CreatedBy",    createdBy),
            ],
            cancellationToken);
    }

    public async Task RespondToReturnAsync(
        int returnId, int sellerId, bool accept, string sellerResponse, int modifiedBy,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_RespondToReturn",
            [
                SqlHelper.Input("@ReturnId",       returnId),
                SqlHelper.Input("@SellerId",       sellerId),
                SqlHelper.Input("@Accept",         accept),
                SqlHelper.Input("@SellerResponse", sellerResponse),
                SqlHelper.Input("@ModifiedBy",     modifiedBy),
            ],
            cancellationToken);
    }

    public async Task<PaginatedResult<MarketplaceReturnDto>> GetMarketplaceReturnsAsync(
        string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var items = await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Admin_GetMarketplaceReturns",
            reader =>
            {
                var total = SqlHelper.GetValue<int>(reader, "TotalCount");
                return (Item: MapMarketplaceReturn(reader), Total: total);
            },
            [
                SqlHelper.Input("@StatusFilter", statusFilter),
                SqlHelper.Input("@PageNumber",   pageNumber),
                SqlHelper.Input("@PageSize",     pageSize),
            ],
            cancellationToken);

        int totalCount = items.Count > 0 ? items[0].Total : 0;
        return new PaginatedResult<MarketplaceReturnDto>(items.Select(x => x.Item).ToList(), pageNumber, pageSize, totalCount);
    }

    public async Task ResolveMarketplaceReturnAsync(
        int returnId, string resolution, decimal? refundAmount, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ResolveMarketplaceReturn",
            [
                SqlHelper.Input("@ReturnId",     returnId),
                SqlHelper.Input("@Resolution",   resolution),
                SqlHelper.InputNullable("@RefundAmount", refundAmount),
                SqlHelper.Input("@AdminId",      adminId),
            ],
            cancellationToken);
    }

    // ── Payouts ───────────────────────────────────────────────────────────

    public async Task<RunPayoutResultDto> RunSellerPayoutAsync(
        int sellerId, DateOnly periodStart, DateOnly periodEnd, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_RunSellerPayout";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@SellerId",    sellerId),
            SqlHelper.Input("@PeriodStart", periodStart.ToDateTime(TimeOnly.MinValue)),
            SqlHelper.Input("@PeriodEnd",   periodEnd.ToDateTime(TimeOnly.MinValue)),
            SqlHelper.Input("@AdminId",     adminId),
        });
        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new RunPayoutResultDto(
                Id:        SqlHelper.GetValue<int>(reader, "Id"),
                NetPayout: SqlHelper.GetValue<decimal>(reader, "NetPayout"));
        }
        return new RunPayoutResultDto(0, 0);
    }

    public async Task<PaginatedResult<SellerPayoutDto>> GetSellerPayoutsAsync(
        int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var items = await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetSellerPayouts",
            reader =>
            {
                var total = SqlHelper.GetValue<int>(reader, "TotalCount");
                return (Item: new SellerPayoutDto(
                    Id:                 SqlHelper.GetValue<int>(reader, "Id"),
                    SellerId:           SqlHelper.GetValue<int>(reader, "SellerId"),
                    PeriodStart:        DateOnly.FromDateTime(SqlHelper.GetValue<DateTime>(reader, "PeriodStart")),
                    PeriodEnd:          DateOnly.FromDateTime(SqlHelper.GetValue<DateTime>(reader, "PeriodEnd")),
                    GrossSales:         SqlHelper.GetValue<decimal>(reader, "GrossSales"),
                    CommissionDeducted: SqlHelper.GetValue<decimal>(reader, "CommissionDeducted"),
                    NetPayout:          SqlHelper.GetValue<decimal>(reader, "NetPayout"),
                    Status:             SqlHelper.GetValue<string>(reader, "Status"),
                    ProcessedOn:        SqlHelper.GetNullableValue<DateTime>(reader, "ProcessedOn"),
                    Reference:          SqlHelper.GetNullableString(reader, "Reference"),
                    CreatedOn:          SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
                Total: total);
            },
            [
                SqlHelper.Input("@SellerId",   sellerId),
                SqlHelper.Input("@PageNumber", pageNumber),
                SqlHelper.Input("@PageSize",   pageSize),
            ],
            cancellationToken);

        int totalCount = items.Count > 0 ? items[0].Total : 0;
        return new PaginatedResult<SellerPayoutDto>(items.Select(x => x.Item).ToList(), pageNumber, pageSize, totalCount);
    }

    // ── Messaging ─────────────────────────────────────────────────────────

    public async Task<int> CreateMessageThreadAsync(
        int sellerId, string subject, string body, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_CreateMessageThread",
            [
                SqlHelper.Input("@SellerId",  sellerId),
                SqlHelper.Input("@Subject",   subject),
                SqlHelper.Input("@Body",      body),
                SqlHelper.Input("@CreatedBy", createdBy),
            ],
            cancellationToken);
    }

    public async Task<int> SendMessageAsync(
        int threadId, int senderUserId, string body, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Marketplace_SendMessage",
            [
                SqlHelper.Input("@ThreadId",     threadId),
                SqlHelper.Input("@SenderUserId", senderUserId),
                SqlHelper.Input("@Body",         body),
                SqlHelper.Input("@CreatedBy",    createdBy),
            ],
            cancellationToken);
    }

    public async Task<PaginatedResult<MessageThreadSummaryDto>> GetMessageThreadsAsync(
        int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var items = await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetMessageThreads",
            reader =>
            {
                var total = SqlHelper.GetValue<int>(reader, "TotalCount");
                return (Item: new MessageThreadSummaryDto(
                    Id:           SqlHelper.GetValue<int>(reader, "Id"),
                    SellerId:     SqlHelper.GetValue<int>(reader, "SellerId"),
                    Subject:      SqlHelper.GetValue<string>(reader, "Subject"),
                    IsResolved:   SqlHelper.GetValue<bool>(reader, "IsResolved"),
                    MessageCount: SqlHelper.GetValue<int>(reader, "MessageCount"),
                    UnreadCount:  SqlHelper.GetValue<int>(reader, "UnreadCount"),
                    CreatedOn:    SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                    ModifiedOn:   SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn")),
                Total: total);
            },
            [
                SqlHelper.Input("@SellerId",   sellerId),
                SqlHelper.Input("@PageNumber", pageNumber),
                SqlHelper.Input("@PageSize",   pageSize),
            ],
            cancellationToken);

        int totalCount = items.Count > 0 ? items[0].Total : 0;
        return new PaginatedResult<MessageThreadSummaryDto>(items.Select(x => x.Item).ToList(), pageNumber, pageSize, totalCount);
    }

    public async Task<IReadOnlyList<MessageDto>> GetMessagesByThreadAsync(
        int threadId, int sellerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetMessagesByThread",
            reader => new MessageDto(
                Id:           SqlHelper.GetValue<int>(reader, "Id"),
                ThreadId:     SqlHelper.GetValue<int>(reader, "ThreadId"),
                SenderUserId: SqlHelper.GetValue<int>(reader, "SenderUserId"),
                Body:         SqlHelper.GetValue<string>(reader, "Body"),
                ReadAt:       SqlHelper.GetNullableValue<DateTime>(reader, "ReadAt"),
                CreatedOn:    SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
            [
                SqlHelper.Input("@ThreadId", threadId),
                SqlHelper.Input("@SellerId", sellerId),
            ],
            cancellationToken);
    }

    // ── Delivery options ──────────────────────────────────────────────────

    public async Task<IReadOnlyList<SellerDeliveryOptionDto>> GetSellerDeliveryOptionsAsync(
        int sellerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Marketplace_GetSellerDeliveryOptions",
            reader => new SellerDeliveryOptionDto(
                Id:                   SqlHelper.GetValue<int>(reader, "Id"),
                SellerId:             SqlHelper.GetValue<int>(reader, "SellerId"),
                DeliveryType:         SqlHelper.GetValue<string>(reader, "DeliveryType"),
                Price:                SqlHelper.GetValue<decimal>(reader, "Price"),
                FreeThresholdAmount:  SqlHelper.GetNullableValue<decimal>(reader, "FreeThresholdAmount"),
                EstimatedDaysMin:     SqlHelper.GetValue<int>(reader, "EstimatedDaysMin"),
                EstimatedDaysMax:     SqlHelper.GetValue<int>(reader, "EstimatedDaysMax"),
                IsActive:             SqlHelper.GetValue<bool>(reader, "IsActive"),
                CreatedOn:            SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                ModifiedOn:           SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn")),
            [SqlHelper.Input("@SellerId", sellerId)],
            cancellationToken);
    }

    public async Task UpsertDeliveryOptionAsync(
        int sellerId, UpsertDeliveryOptionDto dto, int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Marketplace_UpsertDeliveryOption",
            [
                SqlHelper.Input("@SellerId",            sellerId),
                SqlHelper.Input("@DeliveryType",        dto.DeliveryType),
                SqlHelper.Input("@Price",               dto.Price),
                SqlHelper.InputNullable("@FreeThresholdAmount", dto.FreeThresholdAmount),
                SqlHelper.Input("@EstimatedDaysMin",    dto.EstimatedDaysMin),
                SqlHelper.Input("@EstimatedDaysMax",    dto.EstimatedDaysMax),
                SqlHelper.Input("@IsActive",            dto.IsActive),
                SqlHelper.Input("@UserId",              userId),
            ],
            cancellationToken);
    }

    // ── Performance ───────────────────────────────────────────────────────

    public async Task<SellerPerformanceDto?> GetLatestPerformanceAsync(
        int sellerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Marketplace_GetLatestPerformance",
            reader => new SellerPerformanceDto(
                Id:                 SqlHelper.GetValue<int>(reader, "Id"),
                SellerId:           SqlHelper.GetValue<int>(reader, "SellerId"),
                ScoreDate:          DateOnly.FromDateTime(SqlHelper.GetValue<DateTime>(reader, "ScoreDate")),
                OnTimeDeliveryRate: SqlHelper.GetNullableValue<decimal>(reader, "OnTimeDeliveryRate"),
                ReturnRate:         SqlHelper.GetNullableValue<decimal>(reader, "ReturnRate"),
                CancellationRate:   SqlHelper.GetNullableValue<decimal>(reader, "CancellationRate"),
                AverageRating:      SqlHelper.GetNullableValue<decimal>(reader, "AverageRating"),
                OverallScore:       SqlHelper.GetNullableValue<decimal>(reader, "OverallScore"),
                BelowThreshold:     SqlHelper.GetValue<bool>(reader, "BelowThreshold"),
                CreatedOn:          SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
            [SqlHelper.Input("@SellerId", sellerId)],
            cancellationToken);
    }

    private static MarketplaceReturnDto MapMarketplaceReturn(SqlDataReader reader) =>
        new(
            Id:             SqlHelper.GetValue<int>(reader, "Id"),
            OrderLineId:    SqlHelper.GetValue<int>(reader, "OrderLineId"),
            SellerId:       SqlHelper.GetValue<int>(reader, "SellerId"),
            SellerName:     SqlHelper.GetNullableString(reader, "SellerName"),
            UserId:         SqlHelper.GetValue<int>(reader, "UserId"),
            ReturnReason:   SqlHelper.GetValue<string>(reader, "ReturnReason"),
            SellerResponse: SqlHelper.GetNullableString(reader, "SellerResponse"),
            Resolution:     SqlHelper.GetNullableString(reader, "Resolution"),
            StatusName:     SqlHelper.GetValue<string>(reader, "StatusName"),
            SlaDeadline:    SqlHelper.GetValue<DateTime>(reader, "SlaDeadline"),
            ResolvedOn:     SqlHelper.GetNullableValue<DateTime>(reader, "ResolvedOn"),
            RefundAmount:   SqlHelper.GetNullableValue<decimal>(reader, "RefundAmount"),
            CreatedOn:      SqlHelper.GetValue<DateTime>(reader, "CreatedOn"));
}
