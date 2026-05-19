using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Promotions.DTOs;
using TescoClone.Application.Promotions.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Promotions;

// ADO.NET repository for promotions: admin CRUD and storefront active-promotion listing (separate SPs for each context).
public sealed class PromotionRepository : IPromotionRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<PromotionRepository> _logger;

    public PromotionRepository(SqlConnectionFactory connectionFactory, ILogger<PromotionRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<PromotionDto>> GetPromotionsAsync(
        bool? isActive, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetPromotions";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.InputNullable("@IsActive", isActive),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<PromotionDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapPromotion(reader));
        }

        return new PaginatedResult<PromotionDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<PromotionDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Admin_GetPromotionById",
            MapPromotion,
            [SqlHelper.Input("@PromotionId", id)],
            cancellationToken);
    }

    public async Task<int> CreateAsync(PromotionDto promotion, int typeId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Admin_CreatePromotion",
            [
                SqlHelper.Input("@Name", promotion.Name),
                SqlHelper.Input("@TypeId", typeId),
                SqlHelper.InputNullable("@DiscountValue", promotion.DiscountValue),
                SqlHelper.InputNullable("@DiscountPercent", promotion.DiscountPercent),
                SqlHelper.InputNullable("@MinQuantity", promotion.MinQuantity),
                SqlHelper.InputNullable("@StartsAt", promotion.StartsAt),
                SqlHelper.InputNullable("@EndsAt", promotion.EndsAt),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task UpdateAsync(PromotionDto promotion, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UpdatePromotion",
            [
                SqlHelper.Input("@PromotionId", promotion.Id),
                SqlHelper.Input("@Name", promotion.Name),
                SqlHelper.InputNullable("@DiscountValue", promotion.DiscountValue),
                SqlHelper.InputNullable("@DiscountPercent", promotion.DiscountPercent),
                SqlHelper.InputNullable("@MinQuantity", promotion.MinQuantity),
                SqlHelper.InputNullable("@StartsAt", promotion.StartsAt),
                SqlHelper.InputNullable("@EndsAt", promotion.EndsAt),
                SqlHelper.Input("@IsActive", promotion.IsActive),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task<PaginatedResult<PromotionDto>> GetActivePromotionsForStorefrontAsync(
        int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Promotions_GetActivePromotions";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<PromotionDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapPromotionStorefront(reader));
        }

        return new PaginatedResult<PromotionDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task SoftDeleteAsync(int id, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SoftDeletePromotion",
            [
                SqlHelper.Input("@PromotionId", id),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    private static PromotionDto MapPromotion(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            Name: SqlHelper.GetValue<string>(reader, "Name"),
            TypeName: SqlHelper.GetValue<string>(reader, "TypeName"),
            DiscountValue: SqlHelper.GetNullableValue<decimal>(reader, "DiscountValue"),
            DiscountPercent: SqlHelper.GetNullableValue<decimal>(reader, "DiscountPercent"),
            MinQuantity: SqlHelper.GetNullableValue<int>(reader, "MinQuantity"),
            StartsAt: SqlHelper.GetNullableValue<DateTime>(reader, "StartsAt"),
            EndsAt: SqlHelper.GetNullableValue<DateTime>(reader, "EndsAt"),
            IsActive: SqlHelper.GetValue<bool>(reader, "IsActive"),
            RequiresClubcard: false,
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));

    private static PromotionDto MapPromotionStorefront(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            Name: SqlHelper.GetValue<string>(reader, "Name"),
            TypeName: SqlHelper.GetValue<string>(reader, "TypeName"),
            DiscountValue: SqlHelper.GetNullableValue<decimal>(reader, "DiscountValue"),
            DiscountPercent: SqlHelper.GetNullableValue<decimal>(reader, "DiscountPercent"),
            MinQuantity: SqlHelper.GetNullableValue<int>(reader, "MinQuantity"),
            StartsAt: SqlHelper.GetNullableValue<DateTime>(reader, "StartsAt"),
            EndsAt: SqlHelper.GetNullableValue<DateTime>(reader, "EndsAt"),
            IsActive: SqlHelper.GetValue<bool>(reader, "IsActive"),
            RequiresClubcard: SqlHelper.GetValue<bool>(reader, "RequiresClubcard"),
            CreatedOn: DateTime.UtcNow,
            ModifiedOn: null);
}
