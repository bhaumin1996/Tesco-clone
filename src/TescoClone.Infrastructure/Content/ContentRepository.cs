using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Content.DTOs;
using TescoClone.Application.Content.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Content;

public sealed class ContentRepository : IContentRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<ContentRepository> _logger;

    public ContentRepository(SqlConnectionFactory connectionFactory, ILogger<ContentRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<PageDto>> GetPagesAsync(
        bool? isPublished, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetPages";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.InputNullable("@IsPublished", isPublished),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<PageDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapPage(reader));
        }

        return new PaginatedResult<PageDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<PageDto?> GetPageByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Admin_GetPageById",
            MapPage,
            [SqlHelper.Input("@PageId", id)],
            cancellationToken);
    }
    public async Task<PageDto?> GetPageBySlugAsync(string slug, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Content_GetPageBySlug",
            MapPage,
            [SqlHelper.Input("@Slug", slug)],
            cancellationToken);
    }

    public async Task<int> CreatePageAsync(PageDto page, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Admin_CreatePage",
            [
                SqlHelper.Input("@Title", page.Title),
                SqlHelper.Input("@Slug", page.Slug),
                SqlHelper.Input("@Content", page.Content),
                SqlHelper.Input("@IsPublished", page.IsPublished),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task UpdatePageAsync(PageDto page, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UpdatePage",
            [
                SqlHelper.Input("@PageId", page.Id),
                SqlHelper.Input("@Title", page.Title),
                SqlHelper.Input("@Content", page.Content),
                SqlHelper.Input("@IsPublished", page.IsPublished),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task SoftDeletePageAsync(int id, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SoftDeletePage",
            [
                SqlHelper.Input("@PageId", id),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task<IReadOnlyList<BannerDto>> GetBannersAsync(bool? isActive, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Admin_GetBanners",
            MapBanner,
            [SqlHelper.InputNullable("@IsActive", isActive)],
            cancellationToken);
    }

    public async Task<int> CreateBannerAsync(BannerDto banner, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Admin_CreateBanner",
            [
                SqlHelper.Input("@Title", banner.Title),
                SqlHelper.Input("@SubTitle", banner.SubTitle),
                SqlHelper.Input("@ImageUrl", banner.ImageUrl),
                SqlHelper.Input("@LinkUrl", banner.LinkUrl),
                SqlHelper.Input("@DisplayOrder", banner.DisplayOrder),
                SqlHelper.Input("@IsActive", banner.IsActive),
                SqlHelper.InputNullable("@StartsAt", banner.StartsAt),
                SqlHelper.InputNullable("@EndsAt", banner.EndsAt),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task UpdateBannerAsync(BannerDto banner, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UpdateBanner",
            [
                SqlHelper.Input("@BannerId", banner.Id),
                SqlHelper.Input("@Title", banner.Title),
                SqlHelper.Input("@SubTitle", banner.SubTitle),
                SqlHelper.Input("@ImageUrl", banner.ImageUrl),
                SqlHelper.Input("@LinkUrl", banner.LinkUrl),
                SqlHelper.Input("@DisplayOrder", banner.DisplayOrder),
                SqlHelper.Input("@IsActive", banner.IsActive),
                SqlHelper.InputNullable("@StartsAt", banner.StartsAt),
                SqlHelper.InputNullable("@EndsAt", banner.EndsAt),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task SoftDeleteBannerAsync(int id, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SoftDeleteBanner",
            [
                SqlHelper.Input("@BannerId", id),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    private static PageDto MapPage(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            Title: SqlHelper.GetValue<string>(reader, "Title"),
            Slug: SqlHelper.GetValue<string>(reader, "Slug"),
            Content: SqlHelper.GetNullableString(reader, "Content"),
            IsPublished: SqlHelper.GetValue<bool>(reader, "IsPublished"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));

    private static BannerDto MapBanner(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            Title: SqlHelper.GetValue<string>(reader, "Title"),
            SubTitle: SqlHelper.GetNullableString(reader, "SubTitle"),
            ImageUrl: SqlHelper.GetNullableString(reader, "ImageUrl"),
            LinkUrl: SqlHelper.GetNullableString(reader, "LinkUrl"),
            DisplayOrder: SqlHelper.GetValue<int>(reader, "DisplayOrder"),
            IsActive: SqlHelper.GetValue<bool>(reader, "IsActive"),
            StartsAt: SqlHelper.GetNullableValue<DateTime>(reader, "StartsAt"),
            EndsAt: SqlHelper.GetNullableValue<DateTime>(reader, "EndsAt"),
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));
}
